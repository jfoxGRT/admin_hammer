require 'cgi'
require 'bson'
require 'json'

class TwentyfourhourController < ApplicationController

  def index
    intervals = AaeTwentyFourHourStats.descending(:_id).limit(500)
    process_intervals(intervals)
    @first_interval = (AaeTwentyFourHourStats.ascending(:_id).limit(1))[0][:_id].to_f.to_i.to_json
  end

  def range
    gte = Time.at(Float(params[:_from])/1000)
    lt = Time.at(Float(params[:_to])/1000)
    intervals = AaeFiveMinuteStats.where(:_id => {"$gte" => gte}).and(:_id => {"$lt" => lt})
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
