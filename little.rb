#config
require 'sinatra'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'rubygems'
require 'json'
require 'net/http'
require 'active_support/all'
require 'xmlsimple'
require 'digest/sha2'

set :port, 80
set :public_folder, 'public'
set :environment, :development




get '/meta.json' do

	erb :meta
end

get '/edition/' do
	
	
	#Returns errors if parameters not supplied
	return 400, 'Error: No country' if params['c'].nil?
	return 400, 'No delivery time supplied' if params['local_delivery_time'].nil?
	
	#Only displays if it is Friday
	date = Time.parse(params['local_delivery_time'])
	#Return if today is not friday
	return unless date.friday?


	@country = params[:c]
	#Variable for iTunes xml as an array
	@final = XmlSimple.xml_in(Net::HTTP.get("itunes.apple.com","/#{@country}/rss/topsongs/limit=5/xml"))#get XML and convert into array
	
	etag Digest::SHA2.hexdigest(@final['entry'][0]['title'][0]+@final['entry'][1]['title'][0]+@final['entry'][2]['title'][0]+@final['entry'][3]['title'][0]+@final['entry'][4]['title'][0])
	#if the songs have changed, choose this view
	erb :littlenew
end

#security
get '/' do

	"no peeking!"
end


get '/sample/' do

	erb :sample
end


post '/validate_config/' do

  response = {}
  response[:errors] = []
  response[:valid] = true


  if params[:config].nil?
  	return 400, "You didn't post a config"
  end

  settings = JSON.parse(params[:config])

  if settings['country'].nil? || settings['country'] == ""
  	response[:valid] = false
  	response[:errors].push("Please select a country")
  end

  content_type :json
  response.to_json
end
