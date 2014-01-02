require 'rubygems'
require 'mongo'
require 'json'
require 'bson'
require 'optparse'

################################################################################
# main ()
#

def main()

  # parse the command line opts
  options = parse_options()

  # set up connections to mongodb
  db = Mongo::Connection.new("127.0.0.1").db("sam_connect")
  events = db.collection("agent_audit_event")
  stats_coll_name = "aae_five_minute_stats"

  if (!options[:twentyfour].nil?) 
    interval = 24 * 60 * 60 
    stats_coll_name = "aae_twenty_four_hour_stats"
  else
    interval = 5 * 60 
  end

  stats = db.collection(stats_coll_name)
  
  start_time = get_start_time(options, events, stats)
  end_time = get_end_time(options, events, start_time)

  puts ("start time: "+start_time.to_s)
  puts ("  end time: "+end_time.to_s)

  query_start = start_time
  
  while (query_start < end_time) 
    
    if options[:per_run].nil? 
      query_end = end_time
    else
      query_end = query_start + (interval * options[:per_run])
    end
    
    puts("start: "+query_start.to_s+"   end:  "+query_end.to_s);

    query_params =  {
      '$gte' => BSON::ObjectId.from_time(query_start), 
      '$lt' => BSON::ObjectId.from_time(query_end) 
    }
    
    # run the MapReduce
    results = events.map_reduce(get_map(interval), 
                                get_reduce, 
                                :finalize => get_finalize, 
                                :out => {:merge => stats_coll_name},
                                :query => { "_id" => query_params }
                                )
    query_start = query_end
  end
end # end main

################################################################################
# parse_options()
#   parse s the command line options and stores results in options hash
#

def parse_options()
  options = {}
 
  optparse = OptionParser.new do |opts|
    # Set up the help banner

    opts.banner = "\nUsage: get_stats [options] ...\n\n"
    
    # Define the options

    opts.on( '-s','--start_time START',  
             Integer,  
             'Start collecting stats from START (seconds since the epoch)' 
             ) do |s|
      options[:start_time] = s
    end

    opts.on( '-e','--end_time END',  
             Integer,  
             'Collecting stats up to END (seconds since the epoch)' ) do |e|
      options[:end_time] = e
    end

    opts.on( '-m','--minutes MINUTES',  
             Integer,  
             'Collect stats for MINUTES' 
             ) do |m|
      options[:minutes] = m
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

    opts.on( '-i','--intervals_per_run INTS',  
             Integer,  
             'process INTS time intervals at a time' 
             ) do |p|
      options[:per_run] = p
    end

    opts.on( '-t','--twenty_four_hour',  
             'gather stats for twenty four hour intervals instead of 5 min' 
             ) do |t|
      options[:twentyfour] = t
    end

    opts.on( '-u', '--usage', 'Display this screen' ) do
      puts (opts)
      print <<-'EOF'

        The --start_time and --end_time options expect a time argument in the
        the form of seconds since the epoch, e.g.:

        --start_time=`date --date "2011-03-21" +%s`

        The --hours, --minutes, and --days options are used to specify the 
        the length of the time span for which we want to accumulate statistics. 
        These options are mutually exclusive with each other and with 
        --end_time.

        Normal usage of this script is to run it with out any options, 
        in which case it gathers statistics for all times since the last
        interval for whch we already have saved statistics.

        The --intervals_per_run is really just for experimental purposes. It
        allows use to limit the map reduce to the specified number of
        intervals each time it is run (and implies multiple map reduces
        per invocation of the script).

      EOF

      exit 0
    end
    
  end
  
  optparse.parse!

  xoptions = options.clone()

  xoptions.delete_if do |key, value|
    (key == :start_time || key == :per_run || key = :twentyfour)
  end
  
  if (xoptions.size > 1) then

    puts "You have selected mutually exclusive options:"

    xoptions.each do |key, val|
      case key
      when :minutes
        puts "   --minutes"
      when :hours
        puts "   --hours"
      when :days
        puts "   --days"
      when :end_time
        puts "  --end_time"
      end # end case
    end # end do
    puts
    puts optparse.to_s
    exit 1

  end #end if

  return options

end # end parse_options

################################################################################
# get_start_time()
#   
# start_time: if we have specified start time on the command line then use
# that. If we have not specified a start time then we look at the stats 
# collection and use the timestamp (_id) of the latest there. if there is 
# nothing in the stats directory, use the first _id from events.

def get_start_time(options, events, stats)
  start_time = nil

  if (!options[:start_time].nil?) then # use the value from the command line

    start_time =  Time.at(options[:start_time]);

  else # find the latest in our stats collection

    find_latest_options = { 
      :fields => [ '_id' ], 
      :limit => 1, 
      :sort => ['_id' , Mongo::DESCENDING] 
    }

    stats.find( {}, find_latest_options ).each do |doc| 
      start_time = doc["_id"]
      
    end # end each

  end # end if
  
  if (start_time.nil?)
    # we need to find the oldest record in the events collection
    events.find({},
                :fields => [ '_id' ],
                :limit => 1,
                :sort => [ '_id', Mongo::ASCENDING ]
                ).each { |doc| start_time = doc["_id"].generation_time() }
    
  end

  return start_time
end

################################################################################
# get_end_time()
#   
#

def get_end_time(options, events, start_time)
 
  end_time = nil

  if (!options[:end_time].nil?) then # it was on the command line

    end_time = Time.at(options[:end_time]);

  else 

    add_seconds = nil
      
    # only one of the following three is possible for five minute stats, and
    # only :days is possilbe for 24 hour stats

    if (!options[:hours].nil?)
        add_seconds = 3600 * options[:hours]
    end
    
    if (!options[:days].nil?)
      add_seconds = 3600 * 24 * options[:days]
    end
    
    if (!options[:minutes].nil?)
      add_seconds = 60 * options[:minutes]
    end
    
    if (!add_seconds.nil?) 
      end_time = start_time + add_seconds
    else
      events.find({},
                  :fields => [ '_id' ],
                  :limit => 1,
                  :sort => [ '_id', Mongo::DESCENDING ]
                  ).each { |doc| end_time = doc["_id"].generation_time() + 1 }
    end

    return end_time

  end

end

################################################################################
# get_map():
#   returns a string representing the javascript map method that we will pass
#   to MapReduce
#

def get_map(interval) 
  map_js = <<-"END_OF_MAP"
    function() {
      if (this.tokenDirection == "INCOMING") { 
        var time = this._id.getTimestamp();
        var millisperinterval = 1000 * #{interval};
        var remainder = time % millisperinterval;
        var interval = new Date(parseInt((time - remainder).toFixed(0)));
        var tokenCommandId = this.tokenCommandId;
        var guid = this.tokenMachineGuid;
        var guidHash = {};
        guidHash[guid] = 1
        var commandHash = {};
        commandHash[tokenCommandId] = 1;
        emit(interval, 
             { event: 
               { "machineGuids": guidHash,
                 "commandIds": commandHash 
               }
             } 
            );
      }
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
      
        var uniqueMachineGuids = {};
        var commandIds = {};
    
        for (var i = 0; i< values.length; i++) {
            
            for (var ky in values[i].event.machineGuids) { 
                uniqueMachineGuids[ky] = 1;
            }
            
            for (var ky in values[i].event.commandIds) { 
                
                if (commandIds[ky] == undefined) {
                    commandIds[ky]  = values[i].event.commandIds[ky];
                } else {
                    commandIds[ky] +=values[i].event.commandIds[ky];
                }
                
            }
            
        }
        return ({ event: {
                      "machineGuids": uniqueMachineGuids, 
                      "commandIds": commandIds
                  }
                });
    }
        
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
        newVal = {};
        newVal["commands"] = {};
        newVal["summary"] = {};
        newVal["summary"]["unique_agents"] = 0;
        var other = 0;
        var noop = 0;
        var setcred = 0;
        var total = 0;
        
        if(val.event.commandIds["noop"]!=undefined) {
            noop = val.event.commandIds["noop"];
        }
        
        if(val.event.commandIds["setcredentials"]!=undefined) {
            var setcred = val.event.commandIds["setcredentials"];
        }
        
        for (var i in val.event.commandIds) {
            newVal["commands"][i] = val.event.commandIds[i]; 
            total  += newVal["commands"][i];
        }
        
        for (var i in val.event.machineGuids) { 
            newVal["summary"]["unique_agents"] += 1;
        }
        
        newVal["summary"]["unique_agents"] = 
        		parseInt(newVal["summary"]["unique_agents"].toFixed(0));
        
        newVal["summary"]["total"] = total;
        newVal["summary"]["noop_setcred"] = noop + setcred;
        newVal["summary"]["other"] = total - (noop + setcred);
        newVal["summary"]["percent_other"] = 
            parseFloat((100 * (1 - ( (noop + setcred)/total ))).toFixed(2));
        return newVal;
    }
    
    END_OF_FINALIZE
    
return finalize_js
    
end

main()
