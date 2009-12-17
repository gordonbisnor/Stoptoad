require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'crack'

get '/' do
  erb :index 
end

post '/resolve' do
  @key, @site = [params[:key], params[:site]]
  resolve_all
end

def resolve_all
  url = "http://#{@site}.hoptoadapp.com/errors?auth_token=#{@key}" 
  errors = RestClient.get(url)
  errors = Crack::XML.parse(errors)
  unless !defined?(errors["groups"]) || errors["groups"].nil? || errors["groups"].empty?
    errors["groups"].each do |e|
      resolve e["id"] 
    end 
    resolve_all
  else
    erb :completed
  end
end

# Used by resolve_all to resolve a single error
def resolve id    
  RestClient.put("http://#{@site}.hoptoadapp.com/errors/#{id}?auth_token=#{@key}", :group => { 
    :resolved => true
    },
    :auth_token => @key
    )
end
  
