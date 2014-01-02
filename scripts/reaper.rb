#!/usr/bin/env ruby
require 'mongo'
require 'json'
require 'bson'
require 'optparse'

################################################################################
# main ()
#
def main()

  # parse the command line opts
  @options = parse_options()

  # set up some hashes to use for counting heartbeats and events
  @hb_count_found = {}
  @hb_count_removed = {}

  # match_stack is an array of hashes specifying the sequence we are 
  # looking for
  match_stack = [ 
                 {:command => "noop", :type=>"TOKEN_RECEIVED"}, 
                 {:command => "setcredentials", :type=>"TOKEN_SENT"}, 
                 {:command => "setcredentials", :type=>"TOKEN_RECEIVED"},
                 {:command => "noop", :type=>"TOKEN_SENT"}
                ]
  
  # set up connections to mongodb
  @db = Mongo::Connection.new.db("sam_connect")
  @events = @db.collection("agent_audit_event")
  @heartbeats = @db.collection("heartbeats")

  # make sure there is an index on heartbeats collection
  @heartbeats.ensure_index([['a',Mongo::ASCENDING]], :background => true)

  # get current space usage, for comparing to when we finish
  @init_aae_stats = @events.stats()
  @init_hb_stats = @heartbeats.stats()

  # we need a basic signal handler just to make sure if someone sends
  # a cntrl-C (SIGINT) we finish processing whatever heartbeat we are
  # currently dealing with.

  # @harikari is a flag indicating that we should kill ourselves
  # the next time we are between db operations
  # @block is a variable that we set just prior to starting a 
  # db "transaction", it tells the signal handler to postpone
  # killing hte process

  @harikari = false
  @block = false
  @final_proc = Proc.new {}
  
  Signal.trap("INT") do
    case @block
    when false
      @final_proc.call
      wrap_up
    when true
      @harikari = true
      puts "waiting for db operation to finish"
    end
  end

  # get a list of agentIds, either from command line opts or from db
  if (@options[:agentId].nil?) 
    agent_ids = @events.distinct(:agentId)
  else
    agent_ids = @options[:agentId]
  end
  
  # loop through each agentId
  agent_ids.each do |agent_id|
    
    @hb_count_found[agent_id] = 0
    @hb_count_removed[agent_id] = 0

    print "processing agent id: "+agent_id.to_s+","

    # we'll need proc later, possibly in signal handler if we get a SIGINT
    @final_proc = Proc.new { 
      print "found "+ @hb_count_found[agent_id].to_s + " hearbeats, "
      puts "removed "+ @hb_count_removed[agent_id].to_s + " hearbeats"
    }
    
    # we are only interesting in looking at heartbeats that are more 
    # recent (higher _id) then the most recently archived heartbeat
    # (in the heartbeats collection)
    latest_recorded_heartbeat_cur = 
      @heartbeats.find({"a" => agent_id},
                       {:limit => 1, :sort => ["_id",-1]})
    
    if latest_recorded_heartbeat_cur.has_next? 
      latest_recorded_heartbeat = latest_recorded_heartbeat_cur.next_document
      
      print " finding heartbeats after " +
        latest_recorded_heartbeat["_id"].generation_time.to_s

      event_query = {
        "agentId" => agent_id, 
        "_id" => {'$gte' => latest_recorded_heartbeat["_id"]}
      }
    else
      event_query = {"agentId" => agent_id}
    end

    # we are only interested in events with agentIds
    next if agent_id.nil?

    event_list = []

    # let's find all relavent events for this agent, and suck into an array
    @events.find(event_query).each do |event|
      
      # need to account for different style timestamps
      if !event["timestamp"].is_a?(Time)
        if event["timestamp"].has_key?("time")
          event["oldtimestamp"] = event["timestamp"]
          millis = event["oldtimestamp"]["time"] / 1000.0
          event["timestamp"] = Time.at(millis).utc
        else
          puts "WARNING:: has no timstamp: "+event["_id"]
        end
      end
      event_list.push event
    end

    # sorting in mongodb is sort of broken, so let's do it here
    event_list.sort! { |a,b| a["timestamp"] <=> b["timestamp"] }

    print " found "+event_list.length.to_s + " events, "
    if @options[:verbose]
      puts ""
    end

    mycursor = RewindableCursor.new(event_list)

    # loop through the events for this agentId
    while mycursor.has_next? do
      stack = []
      match = true
      
      while (match == true &&
             stack.length < match_stack.length &&
             mycursor.has_next?) 
        
        event = mycursor.next()
        stack.push(event)
        mevent = match_stack[stack.length-1]
        if (event["tokenCommandId"] == mevent[:command] && 
            event["eventType"] == mevent[:type])
          match = true
          else
          match = false
          if (stack.length > 1)
            mycursor.rewind(stack.length - 1) 
          end
        end
      end
        
      # let's see if we have a heartbeat
      if match && stack.length == match_stack.length

        vprint "      ---- heartbeat ----\n" 
        stack.each do |event|
          vprint "**    " 
          vprint event["_id"].to_s + 
            " ("+event["timestamp"].strftime('%Y-%m-%d %H:%M:%S.%L UTC') +
            ") "+event["tokenCommandId"].to_s +
            " "+event["eventType"]+"\n"
        end
        @hb_count_found[agent_id] += 1
              
        # if this is not a dry run, let's do the necessary in the db,
        # including blocking SIGINTS
        if !@options[:dry] 
          block_interrupt() do
            insert_result = @heartbeats.
              insert({:_id => stack[stack.length-1]["_id"], :a => agent_id }, 
                     {:safe => @options[:safe]})
            ids_to_remove = stack.map { |e| e["_id"] }
            vprint "removing " + (ids_to_remove.map { |i| i.to_s }).to_s+"\n\n"
            @events.remove({"_id" => {"$in" => ids_to_remove }},
                           {:safe => @options[:safe]}) 
            @hb_count_removed[agent_id] += 1
          end # end of 'block_interrupt'
        end 
      else # we don't have a heartbeat
        stack.each_index do |i|
          if i == 0 then
            vprint "--    "
          else 
            vprint "      "  
          end
          vprint stack[i]["_id"].to_s +
            " ("+stack[i]["timestamp"].strftime('%Y-%m-%d %H:%M:%S.%L UTC') +
            ") "+stack[i]["tokenCommandId"].to_s +
            " "+stack[i]["eventType"]+"\n"
        end
      end
    end
    @final_proc.call    
  end
  wrap_up
end

################################################################################
# block_interrupt()
#   
#
def block_interrupt()
  @block = true
  yield
  @block = false

  # let's check to see if the signal handler was called, and exit if so
  if @harikari
    @final_proc.call
    wrap_up
  end
end

################################################################################
# wrap_up()
#   cleanly exit
#
def wrap_up()

  # we close and re-open a connection to the database. This is necessary in
  # case we got here via an interrupt, otherwise we deadlock on the connection
  # when we try to use it.
  @db.connection.close()
  @db = Mongo::Connection.new.db("sam_connect")
  events = @db.collection("agent_audit_event")
  heartbeats = @db.collection("heartbeats")

  # let's get our end of run stats
  final_aae_stats = events.stats()
  final_hb_stats = heartbeats.stats()

  # and spit out lots of info about this run
  puts ""
  puts "Initial usage for agent_audit_event: "+
    @init_aae_stats["size"].to_i.to_s+" (used)   "+
    @init_aae_stats["storageSize"].to_i.to_s+" (allocated)   "+
    (@init_aae_stats["storageSize"] - @init_aae_stats["size"]).to_i.to_s +
    " (allocated but unused)"
  puts "  Final usage for agent_audit_event: "+
    final_aae_stats["size"].to_i.to_s+" (used)   "+
    final_aae_stats["storageSize"].to_i.to_s+" (allocated)   "+
    (final_aae_stats["storageSize"] - final_aae_stats["size"]).to_i.to_s +
    " (allocated but unused)"
  puts "                             change: "+
    (final_aae_stats["size"].to_i - @init_aae_stats["size"].to_i).to_s+
    " (used)   "+
    (final_aae_stats["storageSize"].to_i - 
     @init_aae_stats["storageSize"].to_i).to_s+" (allocated)   "+
    ((final_aae_stats["storageSize"] - final_aae_stats["size"])-
     (@init_aae_stats["storageSize"] -@init_aae_stats["size"])).to_i.to_s +
    " (allocated but unused)"
  
  puts ""

  puts "Initial usage for heartbeats: "+
    @init_hb_stats["size"].to_i.to_s+" (used)   "+
    @init_hb_stats["storageSize"].to_i.to_s+" (allocated)   "+
    (@init_hb_stats["storageSize"] - @init_hb_stats["size"]).to_i.to_s +
    " (allocated but unused)"
  puts "  Final usage for heartbeats: "+
    final_hb_stats["size"].to_i.to_s+" (used)   "+
    final_hb_stats["storageSize"].to_i.to_s+" (allocated)   "+
    (final_hb_stats["storageSize"] - final_hb_stats["size"]).to_i.to_s +
    " (allocated but unused)"
  puts "                      change: "+
    (final_hb_stats["size"].to_i - @init_hb_stats["size"].to_i).to_s+
    " (used)   "+
    (final_hb_stats["storageSize"].to_i - 
     @init_hb_stats["storageSize"].to_i).to_s+" (allocated)   "+
    ((final_hb_stats["storageSize"] - final_hb_stats["size"])-
     (@init_hb_stats["storageSize"] - @init_hb_stats["size"])).to_i.to_s +
    " (allocated but unused)"
  puts "found "+ @hb_count_found.values.reduce(:+).to_s + " heartbeats"
  puts "removed "+ @hb_count_removed.values.reduce(:+).to_s + " heartbeats"
  exit
end
  
################################################################################
# vprint()
#   if verbose print the string
#
def vprint(string)
  if @options[:verbose]
    print string
  end
end

################################################################################
# parse_options()
#   parse s the command line options and stores results in options hash
#
def parse_options()
  options = {}
 
  optparse = OptionParser.new do |opts|

    # Set up the help banner    
    opts.banner = "\nUsage: reaper [options] ...\n\n"
    
    # Define the options
    options[:dry] = false
    opts.on( '-d','--dry-run', 'find the heartbeats, '+
             'but don\'t modify the db.') do
      options[:dry] = true 
    end

    options[:safe] = false
    opts.on( '-s','--safe',  
             'use safe mode for db operations') do
      options[:safe] = true
    end
    
    opts.on( '-v','--verbose',  
             'spew out the details') do
      options[:verbose] = true
    end
    
    opts.on( '-a','--agent_id AGENT_ID',  
             Array,  
             "only process events for AGENT_IDs,(a comma "+
             "seperated list, a range, a single number, or a combination "+
             "of these") do |a|
      
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
      options[:agentId] = ids.sort! 
      
    end
  end
  optparse.parse!
  return options
end

################################################################################
# class RewindableCursor
#   this was originally meant to be a proxy to a mongodb cursor, but was 
#   modified accordingly when I realized I need to suck in the entire result
#   set and sort it myself. So now it just works on an array 
#
class RewindableCursor

  def initialize(array)
    @cursor = 0
    @max = array.length
    @array = array
  end
  
  def next()
    rtn = @array[@cursor]
    if @cursor < @max
      @cursor += 1
      return rtn
    else
      return nil
    end
  end

  def rewind(n)
    @cursor -= n
  end

  def has_next?() 
    if (@cursor < @max)
      return true
    else
      return false
    end
  end
end

main()
