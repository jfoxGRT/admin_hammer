require 'cgi'
require 'bson'
require 'json'

class StatsController < ApplicationController

  before_filter :login_required, :set_tab

  # set_tab: sets the @tab variable which is used by layout for highlighting
  # current tab
  def set_tab
    if !params[:interval].nil? && params[:interval] == "24_hr"
      @tab = "24_hour_stats"
      @collection = AaeTwentyFourHourStats
      @interval_size = 60 * 60 * 24
    else
      @tab = "5_minute_stats"
      @collection = AaeFiveMinuteStats
      @interval_size = 300
    end
  end

  def index
    intervals = @collection.descending(:_id).limit(150)
    process_intervals(intervals)
    @first_interval = (@collection.ascending(:_id).limit(1))[0][:_id].to_f.to_i.to_json
  end

  def range
    gte = Time.at(Float(params[:_from])/1000)
    lt = Time.at(Float(params[:_to])/1000)
    intervals = @collection.where(:_id => {"$gte" => gte}).and(:_id => {"$lt" => lt})
    process_intervals(intervals)
    respond_to do |format|
      format.any {
        render :json => { :data => @intervals_data, :keymap => @keymap }, :content_type => 'application/json'
      }
    end
  end
  
  def process_intervals(intervals)
    @keymap = { :commands => {}, :summary => {} }
    @intervals_data = {}    
    intervals.each do |interval|
      timestring = (interval[:_id].to_i() * 1000).to_s()
      @intervals_data[timestring] = {}
      [:commands, :summary].each do |field|
        value_hash = {}
        interval.value[field].each do |key, value|
          if ! @keymap[field].has_key? key
            @keymap[field][key] = @keymap[field].values().size() 
          end
          value_hash[@keymap[field][key]] = value
        end
        @intervals_data[timestring][field] = value_hash
      end
    end
    @data_json = { :data => @intervals_data, :keymap => @keymap }.to_json
  end
end
