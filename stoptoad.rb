require 'rubygems'
require 'sinatra'
require 'rest_client'

get '/' do
  erb :index 
end

get '/resolve' do
  @key, @site = [params[:key], params[:site]]
  resolve_all
end

def resolve_all
  errors = RestClient.get("http://#{@site}.hoptoadapp.com/errors/?auth_token=#{@key}")
  unless errors.blank?
    errors.each do |e|
      resolve e[:id] 
    end 
    resolve_all
  else
    "Stoptoad Complete!"
  end
end

# Used by resolve_all to resolve a single error
def resolve id    
  RestClient.put("http://#{@site}.hoptoadapp.com/errors/#{id}?auth_token=#{@key}", :group => { 
    :resolved => true
    })
end
  
