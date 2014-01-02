require 'json'
require 'uri'
require 'net/http'

class AuthController < ApplicationController

  def set_profile
    token = params[:token];
    base_url = Mongo::Application.config.scat.auth_base_url
    uri = base_url+"services/Profile/"+token.to_s
    u = URI.parse(uri)
    http = Net::HTTP.new(u.host, u.port)
    http.use_ssl = Mongo::Application.config.scat.auth_use_ssl
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(u.request_uri)
    resp = http.request(request)
    profile = JSON.parse(resp.body)
    session[:profile] = profile
    redirect_to :controller => "stats", :action=> "index", :interval=>"5_min" 
  end

end # end of AuthController defn
