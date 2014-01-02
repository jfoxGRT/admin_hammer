require 'cgi'
require 'bson'
require 'json'

class EventsController < ApplicationController
  before_filter :login_required, :set_tab

  # set_tab: sets the @tab variable which is used by layout for highlighting 
  # current tab
  def set_tab
    @tab = "events_by_agent"
  end
  
  # show method: renders json for a given event, requries eventId as parameter
  def show
    id = BSON::ObjectId.from_string(params[:id])
    event = AgentAuditEvent.where(:_id => id).first()
    respond_to { |format| format.any { render :json => event.to_json } }
  end

  # index controller loads the initial search form with parameters
  def index
    commands()
    @agent_id = params[:agent_id].nil? ? nil : 
      params[:agent_id].to_i
    @command_ids = params[:commands].nil? ? nil :
      params[:commands]
    @start_time = params[:start_time].nil? ? nil : 
      Time.at((params[:start_time].to_f/1000) - 1)
    @end_time = params[:end_time].nil? ? nil :
      Time.at((params[:end_time].to_f/1000) - 1)
    @start_obj_id = BSON::ObjectId.from_time(@start_time)
    @end_obj_id = BSON::ObjectId.from_time(@end_time)
  end

  # search for list of events
  def search

    agent_id = params[:agent_id].nil? ? nil : params[:agent_id].to_i
    direction = params[:direction]
    windowid = params[:windowid]
    limit = params[:limit].to_i
    command_ids = params[:commands].split(",")
    start_time = Time.at((params[:start_time].to_f/1000) - 1)
    end_time = Time.at((params[:end_time].to_f/1000) - 1)
    start_obj_id = BSON::ObjectId.from_time(start_time)
    end_obj_id = BSON::ObjectId.from_time(end_time)

    if session[:window].nil? || session[:window][:windowid] != windowid
      session[:window] = { :windowid => windowid ,:last_returned => nil }
    else 
      if !session[:window][:last_returned].nil?
        end_obj_id = session[:window][:last_returned]
      end
    end

    events_array = []
    events = AgentAuditEvent.
      where(:_id.gte => start_obj_id).
      and(:_id.lt => end_obj_id).
      limit(limit)

    if !agent_id.nil? 
      events = events.and(agentId: agent_id) 
    end

    if !command_ids.empty?
      events = events.and(:tokenCommandId.in => command_ids)
    end

    if !direction.nil?
      events = events.and(:tokenDirection => direction)
    end
    
    events = events.only(:_id, :agentId, :tokenCommandId, :tokenDirection, 
                         :eventType, :timestamp, :i).desc(:_id)

    events.each do |event|
      if event["timestamp"].is_a? Time
        event["timestamp_millis"] = event["timestamp"].to_f*1000
      else
        event["timestamp_millis"] = event["timestamp"]["time"].to_f
      end
      e = event.as_document.reject! {|key, value| key == "timestamp"}
      events_array.push(e)
    end

    session[:window][:last_returned] = events_array.last["_id"]

    @events = { "total" => 101, "events" => events_array } #.to_json
    respond_to do |format|
      format.any {
        render :json => @events.to_json
      }
    end 

  end # end of index_by_agent
  
  private
  def commands
    map="function() {h = this.value.commands; for (var c in h){emit (c, 1);}}"
    reduce= "function(key,values) { return {key: 1} }"  
    @commands = []
    results = AaeTwentyFourHourStats.collection.
      map_reduce(map,reduce, {out: {inline: 1}, raw: true}).
      find().to_a()[0][1]
    results.each {|r| @commands.push r["_id"] }
    @commands.sort
  end

end # end of EventsController defn
