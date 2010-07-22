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

def try_http_and_https
  @protocol = "http"
  begin
    yield
  rescue
    if @protocol == "http"
      @protocol = "https"
      retry
    else
      raise $!
    end
  end
end

def resolve_all
  errors = ''
  try_http_and_https do
    errors = RestClient.get("#{@protocol}://#{@site}.hoptoadapp.com/errors?auth_token=#{@key}")
  end

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
  try_http_and_https do
    RestClient.put("#{@protocol}://#{@site}.hoptoadapp.com/errors/#{id}?auth_token=#{@key}", :group => { 
      :resolved => true
      },
      :auth_token => @key
      )
  end
end

