require 'flickraw'

class CitiesController < ApplicationController
  include ApplicationHelper
  
  layout "simple"
  
  before_filter :find_city_from_params, :except => [:country]
  before_filter :find_duffel_count, :except => [:country, :more_pins]
  
  def index
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @city.nil?
    
    @title = @city.city_country.gsub(", United States", "") + " Itineraries, Travel Tips and Things To Do - Duffel Visual Trip Planner"
    @meta_description = "Check out custom guide and itineraries to " + @city.city_country + ", planned and organized by our members on Duffel Visual Trip Planner.  Start collecting ideas and create your personalized travel guide with Duffel!"
    @sub_title = "<a href=\"/explore\">Explore</a> &nbsp;&rsaquo;&nbsp; <a href=\"/country/#{params[:country_code]}\">#{@city.country_name}</a> &nbsp;&rsaquo;&nbsp; #{@city.city}"
    
    # if !fragment_exist?("city-#{@city.city_country}-duffels", :time_to_live => 12.hours)
    #   #################################################
    #   # Find duffels (with comment count) in this city
    #   #################################################
    #   @trips = Trip.find_trips_by_city(@city.id, 6)
    #   
    #   #####################################
    #   # Find users invited to each duffel
    #   ####################################
    #   t = @trips.collect { |x| x.id } # get all the trip ids and store them in an array
    #   @users_by_trip_id = User.find_users_by_trip_ids(t)
    # end
    
    ######################
    # Featured Duffels
    ######################
    @featured = FeaturedDuffel.find_by_city_id(@city.id, :order => "created_at desc")
    
    ######################
    # Find interesting events
    #####################
    @pins = Event.find_ideas_by_city(@city.id, params[:page])
    
    #######################
    # Find Viator events
    #######################
    if !fragment_exist?("city-#{@city.city_country}-activities", :time_to_live => 1.week)
      @activities = ViatorEvent.find_viator_events_by_destination("", 3, @city.id)
    end
    
    #######################
    # Find Flickr Photos
    ######################
    @photos = []
    unless Utility.robot?(request.user_agent)
      if !fragment_exist?("city-#{@city.city_country}-flickr-photos", :time_to_live => 1.week)
        FlickRaw.api_key = ENV['FLICKR_KEY']
        FlickRaw.shared_secret = ENV['FLICKR_SECRET']
        result = flickr.photos.search(:tags => params[:city], :license => '1,2,3,4,5,6', :per_page => 8, :media => 'photo', :content_type => 1, :page => 1, :sort => 'interestingness-desc', :lat => @city.latitude, :lon => @city.longitude, :radius => 32, :accuracy => 10, :extras => 'owner_name')

        tmp = result[0]
        result.each do |p|
          if tmp.ownername != p.ownername
            large_size = flickr.photos.getSizes(:photo_id => p.id).find {|s| s.label == 'Large' }
            if !large_size.nil? and large_size.width.to_i > 960
              @photos << p
              tmp = p
            end
          end
        end
      
        write_fragment("city-#{@city.city_country}-flickr-photos", @photos)
      else
        @photos = read_fragment("city-#{@city.city_country}-flickr-photos")
      end
    end

  end
  
  def country
    @country = City.find_by_country_code(params[:country_code])
    @title = @country.city_country + " - Duffel Visual Trip Planner - Organize Your Travel Itinerary"
    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @country.nil?
    
    @sub_title = "<a href=\"/explore\">Explore</a> &nbsp;&rsaquo;&nbsp; #{@country.city_country}"
    
    #################################################
    # Find duffels (with comment count) in this city
    #################################################
    #@trips = Trip.find_trips_by_city(@country.id, 6)
    
    #####################################
    # Find users invited to each duffel
    ####################################
    #t = @trips.collect { |x| x.id } # get all the trip ids and store them in an array
    #@users_by_trip_id = User.find_users_by_trip_ids(t)
    
    #####################################
    # Find cities for this country and map them
    ####################################
    @top_cities = City.top_cities(@country.country_id)
    
    0.upto(19) do |n| 
      break if @top_cities[n].nil?

      if @top_cities[n].country_code == "US" or @top_cities[n].country_code == "CA"
				@top_cities[n][:url] = na_city_url(:country_code => @top_cities[n].country_code, :region => @top_cities[n].region, :city => city_name_to_url(@top_cities[n].city))
			else
			  @top_cities[n][:url] = city_url(:country_code => @top_cities[n].country_code, :city => city_name_to_url(@top_cities[n].city))
			end
		end
		
		@cities_to_map = @top_cities.to_json
		
		@max_trip_count = (@top_cities.collect {|i| i.trip_count.to_i }).max.to_json
		
  end
  
  def duffels
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 #and return if @city.nil?
    
    @title = "Trips to " + @city.city_country + " - Duffel Visual Trip Planner"
    @meta_description = @city.city_country + " - Duffel is a visual trip planner that changes the way you organize travel research.  Start collecting ideas and create your personalized travel guide with Duffel!"
    
    ##########################################
    # Create query for sorting / filtering
    ##########################################
    case params[:filter]
    when "short"
      # get duration = 1-3 days
      condition = " and (trips.duration > 0 and trips.duration <= 3)"
    when "medium"
      # get duration = 4-7 days
      condition = " and (trips.duration >= 4 and trips.duration <= 7)"
    when "long"
      # get duration = 8+ days
      condition = " and (trips.duration >= 8)"
    when "no_dates"
      # get no start/end date trips
      condition = " and (trips.start_date is null or trips.end_date is null)"
    else # also includes "none"
      # get all trips
      condition = ""
    end
    
    case params[:sort]
    when "popular"
      # sort by popularity
      order = "favorite_count DESC"
    when "featured"
      # sort by featured (not available right now)
    else # also includes "recent"
      # default is sorted by recency
      order = "trips.start_date DESC"
      condition = condition + " and (trips.start_date <= FROM_DAYS(TO_DAYS(CURRENT_DATE)+30) or (trips.created_at <= CURRENT_DATE))"
    end
    
    if !fragment_exist?("more-duffels-#{@city.city_country}-#{params[:sort] || "recent"}-#{params[:filter] || "none"}-#{params[:page] || 1}", :time_to_live => 1.day)
      #################################################
      # Find duffels (with comment count) in this city
      #################################################
      @trips = Trip.find_all_trips_by_city(@city.id, params[:page], 18, order, condition)
      
      #####################################
      # Find users invited to each duffel
      ####################################
      t = @trips.collect { |x| x.id } # get all the trip ids and store them in an array
      @users_by_trip_id = User.find_users_by_trip_ids(t)
    end
  end
  
  def more_pins
    ######################
    # Find interesting events
    #####################
    @pins = Event.find_ideas_by_city(@city.id, params[:page])
  end
   
private

  def find_duffel_count
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @city.nil?
    
    #######################
    # Find duffel counts
    #######################
    if !fragment_exist?("city-#{@city.city_country}-duffel-count", :time_to_live => 1.day)
      @duffel_count = City.count_public_private_duffels(@city.id)
      write_fragment("city-#{@city.city_country}-duffel-count", @duffel_count)
    else
      @duffel_count = read_fragment("city-#{@city.city_country}-duffel-count")
    end
  end

  def find_city_from_params
    @city = City.find_by_city_name_and_country_code(url_to_city_name(params[:city]), params[:country_code], params[:region])
    
    return if @city.nil?
    
    case @city.city_country
    when "New York, NY, United States"
      @image_path = "/images/cities/960x175/new-york.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/fergusonphotography/3056953388/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/fergusonphotography/">http://www.flickr.com/photos/fergusonphotography/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "San Francisco, CA, United States"
      @image_path = "/images/cities/960x175/san-francisco.jpg"
    when "Los Angeles, CA, United States"
      @image_path = "/images/cities/960x175/los-angeles.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/sgt_spanky/3993973823/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/sgt_spanky/">http://www.flickr.com/photos/sgt_spanky/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "London, United Kingdom"
      @image_path = "/images/cities/960x175/london.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/trodel/3599402258/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/trodel/">http://www.flickr.com/photos/trodel/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    when "Rome, Italy"
      @image_path = "/images/cities/960x175/rome.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/raselased/3061381513/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/raselased/">http://www.flickr.com/photos/raselased/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    when "Taipei, Taiwan"
      @image_path = "/images/cities/960x175/taipei.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/22240293@N05/4040465377/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/22240293@N05/">http://www.flickr.com/photos/22240293@N05/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "Sydney, Australia"
      @image_path = "/images/cities/960x175/sydney.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/linh_rom/2270221225/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/linh_rom/">http://www.flickr.com/photos/linh_rom/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "Paris, France"
      @image_path = "/images/cities/960x175/paris.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/trodel/3598596311/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/trodel/">http://www.flickr.com/photos/trodel/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    when "Las Vegas, NV, United States"
      @image_path = "/images/cities/960x175/las-vegas.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/sergemelki/3273603395/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/sergemelki/">http://www.flickr.com/photos/sergemelki/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "Montreal, QC, Canada"
      @image_path = "/images/cities/960x175/montreal.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/trodel/3599395836/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/trodel/">http://www.flickr.com/photos/trodel/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    when "Berlin, Germany"
      @image_path = "/images/cities/960x175/berlin.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/wolfgangstaudt/559627350/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/wolfgangstaudt/">http://www.flickr.com/photos/wolfgangstaudt/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "Tokyo, Japan"
      @image_path = "/images/cities/960x175/tokyo.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/imuttoo/425783124/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/imuttoo/">http://www.flickr.com/photos/imuttoo/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    when "Seattle, WA, United States"
      @image_path = "/images/cities/960x175/seattle.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/howardignatius/3223509093/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/howardignatius/">http://www.flickr.com/photos/howardignatius/</a> / <a rel="license" href="http://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>'
    when "Chicago, IL, United States"
      @image_path = "/images/cities/960x175/chicago.jpg"
      @div_by_txt = '<div xmlns:cc="http://creativecommons.org/ns#" about="http://www.flickr.com/photos/normalityrelief/3276585415/"><a rel="cc:attributionURL" href="http://www.flickr.com/photos/normalityrelief/">http://www.flickr.com/photos/normalityrelief/</a> / <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a></div>'
    else
      @image_path = "/images/cities/960x175/empty.png"
    end
  end
  
end
