require 'rubygems'
require 'mongo'
require 'json'
require 'bson'
require 'optparse'
require 'java'
require 'thread'
require 'timeout'

# Set up some constants
SECONDS_PER_DAY = (60*60*24)

################################################################################
# main ()
#
def main()

  # initialize some counters to keep track of how much we delete
  incoming_noops_deleted = 0
  outgoing_noops_deleted = 0
  incoming_setcreds_deleted = 0
  outgoing_setcreds_deleted = 0
  
  # parse the command line opts
  options = parse_options()
  verbose = options[:verbose]
  
  # how many threads?
  thread_count = options[:threads]

  # how much data are we keeping
  seconds_to_keep = options[:days] * SECONDS_PER_DAY
  
  # set up database connection.
  connection = Mongo::Connection.new("127.0.0.1", 27017)
  db = connection.db("sam_connect", :strict => false)
  aae_collection = db.collection("agent_audit_event")
  last_cleaned_noop_collection = db.collection("last_cleaned_noop")

  # get current space usage, for comparing to when we finish
  init_stats = aae_collection.stats()
  
  # We want to create an BSON ObjectId from a timestamp n days ago.
  now = Time.now.to_f
  save_time = Time.at(now - seconds_to_keep)
  clean_before_oid = BSON::ObjectId.from_time(save_time)
  
  # let's figure out which agent_ids we are interested in (default: all)
  # note that the fastest we to determine what "all" is is to find he highest
  # and just assume every number up to that one (runnning a "distinct" query
  # takes a few minutes :-(
  agent_ids = []
  if options[:agents].nil?
    max_agent_id = 
      aae_collection.find({}, 
                          { :fields=> ["agentId"], 
                            :sort => ["agentId",-1], 
                            :limit => 1 } ).to_a()[0]["agentId"]
    agent_ids = (1..max_agent_id).to_a
  else
    agent_ids = options[:agents]
  end
  
  puts "cleaning up data prior to ObjectId(" + 
    clean_before_oid.to_s+ ") (" +save_time.to_s+")"
  
  # setup some threads to use for querying
  threads = []
  queue_empty = false
  semaphore_agent_ids = Mutex.new
  semaphore_totals = Mutex.new
  (1..thread_count).each do |i|
    
    # we need to sleep for a couple of seconds as a workaround to a jruby 1.6 bug
    sleep 2

    threads << Thread.new do
      Thread.current[:i] = i

      # we are going to open one connection per thread, because the ruby driver 
      # thread pooling never quite worked the way I wanted it to. using t_ to 
      # denote thread-local values
      t_connection = Mongo::Connection.new("127.0.0.1", 27017)
      t_db = t_connection.db("sam_connect", :strict => false)
      t_aae_collection = t_db.collection("agent_audit_event")
      t_last_cleaned_noop_collection = t_db.collection("last_cleaned_noop")

      # set up some query stuff common to all queries
      query_opts = { 
        :timeout => true,
        :fields => ["agentId", "_id", "timestamp", "tokenDirection", 
                    "tokenCommandId"]
      }

      query = { 
        "_id" => {'$lt' => clean_before_oid},  
        "tokenCommandId" => {'$in' => ['setcredentials', 'noop'] } 
      }
      
      # loop until no more agent_ids in the queue

      while !queue_empty do
        agent_id = nil

        # put a mutex around access to agent_ids, and slice off the first value
        semaphore_agent_ids.synchronize do
          if agent_ids.length > 0
            agent_id = agent_ids.slice! 0
          else
            # can't break here because of scope, so set a flag and break after 
            # synchronize block
            queue_empty = true
          end
        end 
        break if queue_empty

        query["agentId"] = agent_id
        noops_list = []

        # let's wrap the rest up in begin/rescue in case it times out,
        # so we can retry if necessary
        retries = 3

        begin

          # if this script has been previously, we can limit our query to _ids
          # newer than the the last cleaned point. This is mostly relevant for
          # incoming noops
          last_cleaned = nil
          t_last_cleaned_noop_collection.find({"_id" => agent_id}, 
                                              :timeout => true) do |cur|
            last_cleaned = cur.next_document
          end
          
          if !last_cleaned.nil?
            query["_id"].merge!({'$gte' => last_cleaned["aae_oid"]})
          end

          # iterate through query results and do the necessary
          t_aae_collection.find(query, query_opts) do |cur|
            cur.each do |e|
              if e["tokenCommandId"] == "setcredentials" ||
                e["tokenDirection"] == "OUTGOING"
                puts "(thread: "+i.to_s+") deleting:  "+event_to_s(e) if verbose
                t_aae_collection.remove({"_id" => e["_id"]})
                
                semaphore_totals.synchronize do
                  case [e["tokenDirection"], e["tokenCommandId"]]
                  when ["INCOMING" , "setcredentials"]
                    incoming_setcreds_deleted += 1
                  when ["OUTGOING" , "setcredentials"]
                    outgoing_setcreds_deleted += 1
                  when ["OUTGOING" , "noop"]
                    outgoing_noops_deleted = 0
                  end
                end
            
              else 
                # must be an incoming noop. we need to account for different 
                # style timestamps
                if !e["timestamp"].is_a?(Time)
                  if e["timestamp"].has_key?("time")
                    millis = e["timestamp"]["time"].fdiv(1000)
                    e["timestamp"] = Time.at(millis).utc
                  else
                    puts "WARNING:: has no timstamp: "+e["_id"].to_s
                  end
                end
                noops_list.push e
              end
            end # end of find cursor
          end
          
          noops_to_save = {}
          
          # sorting in mongodb is sort of broken, so let's do it here
          noops_list.sort! { |a,b| a["timestamp"] <=> b["timestamp"] }
          last_noop = noops_list[0]

          # remove the incoming noops
          noops_list.each do |noop|
            day = noop["timestamp"].to_f.div(SECONDS_PER_DAY)
            if noops_to_save.has_key? day
              # we can delete this one
              puts "(thread: "+i.to_s+") deleting:  "+event_to_s(noop) if verbose
              t_aae_collection.remove({"_id" => noop["_id"]})
              incoming_noops_deleted += 1
            else
              noops_to_save[day] = true
              last_noop = noop
              if last_cleaned.nil? || (last_cleaned["aae_oid"] !=  noop["_id"])
                puts "(thread: "+i.to_s+") saving:    "+event_to_s(noop) if verbose
              end
            end
          end
          
          if !noops_list.empty? &&
              (last_cleaned.nil? || (last_cleaned["aae_oid"] !=  last_noop["_id"]))
            t_last_cleaned_noop_collection.update({"_id" => agent_id}, 
                                                  { "_id" => agent_id, 
                                                    "aae_oid_time" => 
                                                    last_noop["_id"].
                                                    generation_time,
                                                    "aae_oid" => last_noop["_id"],
                                                    "updated_at" => Time.now()
                                                  },
                                                  :upsert => true)
          end
          
        rescue => ex
          if retries > 0
            puts "retrying thread "+i.to_s+" agentId: "+agent_id.to_s
            retries -= 1
            retry
          else 
            puts "giving up on thread "+i.to_s+" agentId: "+agent_id.to_s
          end
        end # end of rescue
      end 
      puts "thread "+i.to_s+" finished"
    end # end of thread
  end
  
  # ideally everything below should get cleaned up, but it works well 
  # enough for now.. 
  while !queue_empty do
    sleep 10
  end
  

  # as soon as one thread finishes, give the others a few seconds to wrap up
  sleep 2

  finished_threads = []
  sleeping_threads = []
  threads.each do |t|
    if t.status.to_s == "false"
      finished_threads.push t
    elsif t.status.to_s == "sleep"
      sleeping_threads.push t
    end
  end
  
  # and kill and straglers
  puts finished_threads.length.to_s + " threads finished running"
  if sleeping_threads.length > 0
    puts "trying to wakesleeping threads: "+
      sleeping_threads.map{|t| t[:i]}.join(" ")
    sleeping_threads.each do |t|
      t.raise()
    end
  end
  

  finished_threads.each {|t| t.join unless t == Thread.current }
  
  # get current space usage, for comparing to start
  final_stats = aae_collection.stats()
  puts"\n** Summary **"
  puts "deleted "+incoming_noops_deleted.to_s+" incoming noops"
  puts "deleted "+outgoing_noops_deleted.to_s+" outgoing noops"
  puts "deleted "+incoming_setcreds_deleted.to_s+" incoming setcredentials"
  puts "deleted "+outgoing_setcreds_deleted.to_s+" outgoing setcredentials"
  
  puts "Initial usage for agent_audit_event: "+
    format_stats(init_stats["size"], init_stats["storageSize"],
                 (init_stats["storageSize"].to_i - init_stats["size"].to_i))
  puts "  Final usage for agent_audit_event: "+
    format_stats(final_stats["size"], final_stats["storageSize"],
                 (final_stats["storageSize"].to_i - final_stats["size"].to_i))
  puts "                             change: "+
      format_stats((final_stats["size"].to_i - init_stats["size"].to_i),
                   (final_stats["storageSize"].to_i - 
                    init_stats["storageSize"].to_i),
                   ((final_stats["storageSize"].to_i - final_stats["size"].to_i)-
                    (init_stats["storageSize"].to_i - init_stats["size"].to_i)))
  
end
  
################################################################################
# format_stats()
#
#
def format_stats(used, allocated, unused)
  return format("%13d (used)  %13d(allocated)  %13d(allocated but unused)",
                used,allocated,unused)
end

################################################################################
# event_to_s()
#   format an event for printing
#
def event_to_s(e)
  return "agentId="+ e["agentId"].to_s+
    " "+e["_id"].to_s+" ("+e["_id"].generation_time.to_s+
    ") " +e["tokenDirection"].to_s+" "+e["tokenCommandId"].to_s
end

################################################################################
# parse_options()
#   parses the command line options and stores results in options hash
#
def parse_options()
  
  # set up some defaults
  options = {
    :days => 90, 
    :verbose => false, 
    :noops_only => false, 
    :threads => 1
  }

  optparse = OptionParser.new do |opts|

    # Set up the help banner    
    opts.banner = "\nUsage: clean_old.rb [options] ...\n\n"
    
    # Define the options
    
    # option for specifying agent id, default is all
    opts.on( '-a','--agent_id AGENT_ID',  
             Array,  
             "only process events for AGENT_IDs") do |a|
      ids = []
      a.each do |s|
        id_range = s.split('-')
        case 
        when id_range.length > 2
          warn "invalid parameter"
          exit(false)
        when id_range.length == 2
          if (id_range[1] !~ /\d+/ || id_range[0].to_i >= id_range[1].to_i)
            warn "invalid parameter (should be a range of numbers)"
            exit (false)
          end
          ids.push( *((id_range[0].to_i..id_range[1].to_i).to_a) )
        when id_range.length ==1 
          ids.push( id_range[0].to_i )
        end
      end
      options[:agents] = ids.sort! 
      
    end

    # option for specifying number of days to keep, default is 90
    opts.on( '-d','--days DAYS',  
             Integer,  
             "remove noops/setcreds older than DAYS, default is 90") do |a|
      options[:days] = a
    end

    # option for specifying number of threads, default is 5
    opts.on( '-t','--threads THREADS',  
             Integer,  
             "number of threads, default is 5") do |a|
      options[:threads] = a
    end

    # option for specifying verbosity
    opts.on( '-v','--verbose',  
             "spew") do |v|
      options[:verbose] = true
    end

    opts.on( '-n','--noops-only',  
             "only proess incoming noops") do |v|
      options[:noops_only] = true
    end

  end

  # parse the options
  optparse.parse!
  return options
end

main
