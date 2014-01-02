#!/usr/bin/env ruby
require 'mongo'
require 'json'
require 'bson'
require 'optparse'
require 'time'

################################################################################
# main ()
#
def main()

  # parse the command line opts
  options = parse_options()

  # set up connections to mongodb
  db = Mongo::Connection.new.db("sam_connect")
  events = db.collection("agent_audit_event")

  # figure out our time span
  # only one of the following is possible
  now = Time.now()
  if (!options[:hours].nil?)
    seconds = 3600 * options[:hours]
  elsif (!options[:days].nil?)
    seconds = 3600 * 24 * options[:days]
  elsif (!options[:minutes].nil?)
    seconds = 60 * options[:minutes]
  else
    seconds = 3600 * 24 * 7
  end

  if !options[:start_time].nil?
    start_time = Time.at(options[:start_time])
    end_time = Time.at(start_time.to_i + seconds)
  else
    start_time = Time.at(now.to_i - seconds)
    end_time = now
  end
  
  # we want to create an BSON ObjectId for start and end times

  start_oid = BSON::ObjectId.from_time(start_time)
  end_oid = BSON::ObjectId.from_time(end_time)
  start_str = start_time.strftime("%Y%m%d%H%M%S")
  end_str = end_time.strftime("%Y%m%d%H%M%S")
  puts "start time: "+start_time.to_s+" start_oid: "+start_oid.to_s
  puts "  end time: "+end_time.to_s+  "   end_oid: "+end_oid.to_s
  results_collection = "commands_by_agent__" + start_str+"_"+end_str
  puts "results to be saved in collection: "+results_collection
  # run the MapReduce
  results = events.map_reduce(get_map(), 
                              get_reduce, 
                              :finalize => get_finalize, 
                              :query => {"_id" => 
                                {'$gte' => start_oid, '$lt' => end_oid}},
                              :out => {:merge => results_collection})
                     
end

################################################################################
# get_map():
#   returns a string representing the javascript map method that we will pass
#   to MapReduce

def get_map() 
  map_js = <<-'END_OF_MAP'
    function() {
          var agent = this.agentId;
          var sum = {};
          sum[this.tokenCommandId] = 1;
					emit(agent, sum  ); 
    }
  END_OF_MAP

  return map_js
end

################################################################################
# get_reduce():
#   returns a string representing the javascript reduce method that we will 
#   pass to MapReduce
  
def get_reduce() 
  reduce_js = <<-'END_OF_REDUCE' 

function(key, values) {
    
		var total = {};
    var rtn = {};

    values.forEach(function(e) {
        for (command in e) {
           if (total[command] == undefined) {
               total[command] = e[command]
           } else {
               total[command] += e[command]
           }
        }
    })
    rtn["sum"] = total
    return (total);
};         
    END_OF_REDUCE
    
  return reduce_js
end

################################################################################
# get_finalize():
#   returns a string representing the javascript finalize method that we will 
#   pass to MapReduce
def get_finalize()
  finalize_js = <<-'END_OF_FINALIZE'
    function(key, val) {
       var newval = {}
       newval["total"] = 0
       print (val.toSource())
       for (command in val) {
//          print ("val["+command+"] = "+ val["command"])
          newval[command] = val[command]
          newval["total"] += val[command]
       }
       return (newval);
    }
    END_OF_FINALIZE
    
return finalize_js
    
end

################################################################################
# parse_options()
#   parse s the command line options and stores results in options hash
#

def parse_options()
  options = {}
 
  optparse = OptionParser.new do |opts|
    # Set up the help banner

    opts.banner = "\nUsage: weekly_agents [options] ...\n\n"
    
    # Define the options

    opts.on( '-s','--start_time START',  
             Integer,  
             'Start collecting stats from START (seconds since the epoch)' 
             ) do |s|
      options[:start_time] = s
    end

    opts.on( '-h','--hours HOURS',  
             Integer,  
             'Collect stats for HOURS' 
             ) do |h|
      options[:hours] = h
    end

    opts.on( '-d','--days DAY',  
             Integer,  
             'Collect stats for DAYS' 
             ) do |d|
      options[:days] = d
    end

    opts.on( '-m','--minutes MINUTES',  
             Integer,  
             'Collect stats for MINUTES' 
             ) do |m|
      options[:minutes] = m
    end

    opts.on( '-u', '--usage', 'Display this screen' ) do
      puts (opts)
      print <<-'EOF'

        --start_time expect a time argument in the the form of seconds since the epoch, e.g.:

        --start_time=`date --date "2011-03-21" +%s`

        The --hours, --minutes and --days options are used to specify the 
        the length of the time span for which we want to accumulate statistics. 
        default is seven days

        Normal usage of this script is to run it with out any options, 
        in which case it gathers statistics for the last week

      EOF

      exit 0
    end
    
  end
  
  optparse.parse!

  xoptions = options.clone()

  xoptions.delete_if do |key, value|
    (key == :start_time)
  end
  
  if (xoptions.size > 1) then

    puts "You have selected mutually exclusive options:"

    xoptions.each do |key, val|
      case key
      when :hours
        puts "   --hours"
      when :days
        puts "   --days"
      when :days
        puts "   --minutes"
      end # end case
    end # end do
    puts
    puts optparse.to_s
    exit 1

  end #end if

  return options

end # end parse_options

main()

