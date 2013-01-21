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
set :environment, :production

DataMapper::Property::Text.length(255) #set text max length (fixing bug which occured when inputting SHA-2)

#Set up datamapper
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/little.db")  
class Songs  
  include DataMapper::Resource  
  property :ident, String, :length => 64
  property :name1, Text  
  property :url1, Text  
  property :name2, Text   
  property :name3, Text   
  property :name4, Text  
  property :name5, Text  
  property :country, String, key: true
end  
DataMapper.finalize.auto_upgrade! 



get '/meta.json' do

	erb :meta
end

get '/edition/' do
	
	
	
	return 400, 'Error: No country' if params[:c].nil?
	return 400, 'No delivery time supplied' if params[:local_delivery_time].nil?
	
	date = Time.parse(params['local_delivery_time'])
	# Return if today is not Monday.
	return unless date.friday?

	@country = params[:c]
	@final = XmlSimple.xml_in(Net::HTTP.get("itunes.apple.com","/#{@country}/rss/topsongs/limit=5/xml"))#get XML and convert into array
	
	#To classify the new incoming top 5
	class Othersong 

		def initialize(num,final)
			@num = num - 1
			@final = final
		end

		def title
			@final['entry'][@num]['title'][0]
		end

		def url
			@final['entry'][@num]['image'][2]['content']
		end
	end

	#making variables to encode
	one = Othersong.new(1,@final)
	two = Othersong.new(2,@final)
	three = Othersong.new(3,@final)
	four = Othersong.new(4,@final)
	five = Othersong.new(5,@final)
	
	#gets row for selected country
	@song = Songs.first country: "#{@country}"
	if @song != nil
		ident = @song.ident
		
		#checks if current country songs are the same as the most recent ones
		if ident != Digest::SHA2.hexdigest(one.title+two.title+three.title+four.title+five.title)
			
			etag Digest::SHA2.hexdigest(@final['entry'][0]['title'][0]+@final['entry'][1]['title'][0]+@final['entry'][2]['title'][0]+@final['entry'][3]['title'][0]+@final['entry'][4]['title'][0])
			#if the songs have changed, choose this view
			erb :littlenew
			
		else

			etag Digest::SHA2.hexdigest(one.title+two.title+three.title+four.title+five.title)
			#if the songs are the same, choose this view
			erb :littleold
			
		end
	
	else
		etag Digest::SHA2.hexdigest(@final['entry'][0]['title'][0]+@final['entry'][1]['title'][0]+@final['entry'][2]['title'][0]+@final['entry'][3]['title'][0]+@final['entry'][4]['title'][0])
		erb :littlenew
	end
end

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
