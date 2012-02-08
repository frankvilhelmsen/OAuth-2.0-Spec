require "rubygems"
require "sinatra"
require 'json'
require "base64" 
require './authorization'

#################################
# Server hocks 
#################################
# encoding: utf-8 

not_found do
    "This is an nonvalid route."
end
# preconditions 
set(:precondition) do |*conditions|  
  condition do
     conditions.each do |pre| 
       if params[pre] == nil 
         data = { "error" => { "message" => "Precondition Failed! Missing #{pre} ", "type" => "invalid request", "exception" => "OAuth Exception"  }  }
         halt 412, JSON.generate(data)
       end
     end
  end
end
get '/debug' do
    puts "#{@request.inspect}"
      "#{@request.inspect}"
end  

helpers do
 include Sinatra::Authorization # require_user_privileges 
end

#################################
# Root context 
#################################
get '/' do
 erb :index
end
#################################
# OAuth 2.0 Client Registration 
#################################
post '/company/apps/registering' do # :precondition => ['appname', 'email', 'siteuri'] do 
  require_user_privileges 
  doc = JSON.parse(request.body.read)
  data = {
    "registration" => { 
      "pending" => "Waiting for verification",
      "appname"=> "#{doc['appname']}", 
      "email" => "#{doc['email']}",
      "client_id" => "19837i4376916044",
      "client_secret" => "37258968804049145bea92056ddae960"
    }
   }
  status 201
  body JSON.generate(data)
end
#################################
# Protected resources 
#################################
before '/protected/*' do
 puts "---------> Security filter inbound "
  if params[:access_token] != nil && params[:access_token] == "MTk4Mzc0Mzc2OTE2MDQ0fDhHWnNGOEZrR3NtRGFLVmtVQjNFMkhiclBfTQ=="
    puts "--------> #{request.path_info} #{params[:access_token]} <---------"
  else
    response["Authorization: OAuth"] = "invalid_request" "An active access token is mandatory"
    data = { "error" => { "message" => "An active access token is mandatory!", "type" => "invalid request", "exception" => "OAuth Exception"  }  }
    halt 401, JSON.generate(data)
  end
end
after '/protected/*' do
  puts "<--------- Security filter outbound "
end
get '/protected/:service' do
   json = JSON.generate({"name" => "frank vilhelmsen", "href" => "/info", "type" => "application/json" })
   callback = params.delete('callback') # jsonp
   if callback
        content_type :js
        response = "#{callback}(#{json})" 
     else
       content_type :json
       response = json
     end
  response
end

#################################
# oauth 
#################################
# curl -i http://known:customer@10.73.21.82:4567/company/authorize
before '/oauth/*' do
  puts "<--------- OAuth filter inbound require_user_privileges"
  require_user_privileges
end

# response_type=token
get '/oauth/dialog', :precondition => ['client_id', 'redirect_uri','response_type' ] do
   path = params[:redirect_uri]
   oauth = Base64.encode64("198374376916044|8GZsF8FkGsmDaKVkUB3E2HbrP_M");
   redirect "#{path}?access_token=#{oauth}"
end

# grant_type=credentials
get '/oauth/access_token', :precondition => ['client_id', 'client_secret', 'grant_type'] do 
  "access_token=198374376916044|8GZsF8FkGsmDaKVkUB3E2HbrP_M"
end


