require 'sinatra'
require 'slim'
require 'yelpster'
require 'gon-sinatra'
require 'geocoder'

Sinatra::register Gon::Sinatra

Yelp.configure(:yws_id          => ENV['YELP_ID'],
               :consumer_key    => ENV['YELP_CONSUMER_KEY'],
               :consumer_secret => ENV['YELP_CONSUMER_SECRET'],
               :token           => ENV['YELP_TOKEN'],
               :token_secret    => ENV['YELP_TOKEN_SECRET'])

include Yelp::V2::Search::Request

client = Yelp::Client.new

request = Location.new(
           :term => "food",
           :city => "Tulare, CA",
           :limit => 20)

get '/' do
  @google_api = ENV['GOOGLE_API']
  
  response = client.search(request)["businesses"]

  @business = response[rand(response.length)]

  coords = Geocoder.coordinates("#{@business["location"]["display_address"]}")


  gon.business_name = @business["name"]
  gon.business_coords_lat = coords[0]
  gon.business_coords_long = coords[1]
  gon.snippet_text = @business["snippet_text"]
  gon.business_image_url = @business["image_url"]
  gon.business_rating = @business["rating_img_url"]
  gon.business_address = @business["location"]["display_address"]
  gon.business_phone_number = @business["display_phone"]

  erb :index, :format => :html5
end