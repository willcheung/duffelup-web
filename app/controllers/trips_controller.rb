class TripsController < ApplicationController
  include ApplicationHelper
  
  layout "simple", :only => [:index, :new, :edit]
  
  before_filter :protect, :only => [:new, :create, :print_itinerary, :edit, :update, :destroy]
  after_filter :clear_trip_and_events_cache, :only => [:update, :destroy]
  
  def index
    @title = "Explore Duffel - Visual Bookmarking Tool and Trip Planner"
    @sub_title = "Explore Duffel"
    @top_cities = City.new
    
    if !fragment_exist?("explore-top-cities", :time_to_live => 1.day)
      @top_cities = City.all
      
      0.upto(79) do |n| 
        break if @top_cities[n].nil? #if db doesn't have 40 cities

        if @top_cities[n].city == ""
          @top_cities[n][:url] = country_url(:country_code => @top_cities[n].country_code)
        elsif @top_cities[n].country_code == "US" or @top_cities[n].country_code == "CA"
  				@top_cities[n][:url] = na_city_url(:country_code => @top_cities[n].country_code, :region => @top_cities[n].region, :city => city_name_to_url(@top_cities[n].city))
  			else
  			  @top_cities[n][:url] = city_url(:country_code => @top_cities[n].country_code, :city => city_name_to_url(@top_cities[n].city))
  			end
  		end
  		
  		@cities_to_map = @top_cities.to_json
      write_fragment("explore-top-cities", @top_cities)
		else
		  @top_cities = read_fragment("explore-top-cities")
		  @cities_to_map = @top_cities.to_json
		end
		
		@max_trip_count = (@top_cities.collect {|i| i.trip_count.to_i }).max.to_json
		
		@featured_members = FeaturedDuffel.find(:all, :limit => 18, :order => 'created_at DESC', :include => :user)
  end
  
  # GET /trips/new
  def new
    @title = "Duffel - Create a new trip"
    @new_page = true # flag to indicate 'new' is being rendered instead of 'edit'
    
    # Get the trip_destination parameter from profile#show page.
    unless params[:trip].nil?
      unless params[:trip][:destination].nil? 
        params[:city] = params[:trip][:destination]
      end
    end
    
    # Check if this page is directed from research page.  Set "back" button's value.
    if params[:back] == "research_page"
      @redirect_url = new_research_path(:idea_website => params[:idea_website], 
                                        :event_title => params[:event_title], 
                                        :jump => params[:jump],
                                        :local => params[:local],
                    										:event_code => params[:event_code],
                    										:trip_code => params[:trip_code],
                    										:idea_phone => params[:idea_phone],
                    										:idea_address => params[:idea_address],
                    										:selection => params[:selection],
                    										:type => params[:type])
                    										
      render :action => 'new_trip_bookmarklet', :layout => 'researches'
    else
      @redirect_url = dashboard_url
    end
  end
  

  def create
    
    if request.post?
      # Monkey patch date format
      params[:trip][:start_date] = parse_date(params[:trip][:start_date]) if not params[:trip][:start_date].nil?
      params[:trip][:end_date] = parse_date(params[:trip][:end_date]) if not params[:trip][:end_date].nil?
      
      @trip = Trip.new(params[:trip])
      if @trip.end_date.nil? or @trip.start_date.nil?
        @trip.duration = Trip::DURATION_FOR_NO_ITINERARY
      else
        @trip.duration = (@trip.end_date - @trip.start_date) # Duration + 1 = Number of days
      end
      
      # All new trips are active
      @trip.active = 1

      unless @trip.destination.empty?
        # Get city ids for this duffel and use id to find a random flickr_photo for the city
        cities = City.find_id_by_city_country(@trip.destination)
        #photos = cities[0].flickr_photos unless cities[0].nil?
        #photo = FlickrPhoto.select_random_photo(cities[0].id) if !cities.nil? and !cities.empty? 
      end
      
      # if !photo.nil? and !photo[0].nil?
      #   @trip.photo_file_name = photo[0].url_square
      #   @trip.photo_content_type = "image/jpeg" 
      #   @trip.photo_file_size = ""
      # end
      
      if @trip.save
        news_fb = "is planning a trip to #{@trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" ")} (#{trip_url(:id => @trip)}) on Duffel Visual Trip Planner. Any recommendations?"
                
        #########################
        # add myself to the trip
        #########################
        Invitation.invite_self(current_user, @trip)
        
        ######################################
        # Add city ids to the trip via
        # has_and_belong_to_many relationship
        ######################################
        @trip.cities << cities
        
        #######################
        # create a sample note
        #######################
        Notes.create_to_bring_note(@trip.id)
        
        ###################################
        # create Viator recommendations
        ###################################
        ViatorEvent.insert_recommendation(@trip.destination, @trip.id)
        
        #################################################
        # create Splendia Hotel recommendations
        #################################################
        if !cities[0].nil?
          if !fragment_exist?("#{cities[0].id}-splendia-hotels", :time_to_live => 1.week)
            splendia_hotels = SplendiaHotel.get_hotel_by_lat_lng(cities[0].latitude, cities[0].longitude)
            write_fragment("#{cities[0].id}-splendia-hotels", splendia_hotels)
          else
            splendia_hotels = SplendiaHotel.new
            splendia_hotels = read_fragment("#{cities[0].id}-splendia-hotels")
          end
          
          SplendiaHotel.insert_recommendation(splendia_hotels, @trip.id, @trip.start_date, @trip.end_date)
        end
        
        ###################################
        # create sample transportation
        ###################################
        Transportation.create_in_duffel(current_user.home_airport_code, 
                                        cities[0], 
                                        @trip.start_date, @trip.end_date, @trip.id,
                                        @trip.destination, "Edit me!")
                                              
        ################################################################################
        # publish stream on fb (only works if fb user has approved extended permission)
        ################################################################################
        if current_user.facebook_user? and @trip.is_public == 1
          WebApp.post_stream_on_fb(current_user.fb_user_id, 
                                  trip_url(:id => @trip),
                                  news_fb,
                                  "Give me ideas") 
        end
        
        ###################################
        # Twitter status update
        ###################################
        if current_user.twitter_user? and @trip.is_public == 1
          s_url = WebApp.shorten_url(trip_url(:id => @trip))
          twitter_client.update("I started planning a trip to #{truncate(@trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" "),50)} on @duffelup #{s_url}", {})
        end
        
        ###################################
        # publish news to activities feed
        ###################################
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::CREATE_TRIP, @trip)
        
        # Set redirect URL for "back" button
        if params[:back] == "research_page"
          flash[:notice] = "#{@trip.title} created.  Start collecting ideas!"
          cookies[:default_trip] = @trip.id.to_s
          redirect_to new_research_path(:idea_website => params[:idea_website], 
                                        :event_title => params[:event_title], 
                                        :jump => params[:jump],
                                        :local => params[:local],
                    										:event_code => params[:event_code],
                    										:trip_code => params[:trip_code],
                    										:idea_phone => params[:idea_phone],
                    										:idea_address => params[:idea_address],
                    										:selection => params[:selection],
                    										:type => params[:type])
        elsif params[:invite] == "true"
          flash[:notice] = "#{@trip.title} created.  Invite friends and start collecting ideas!"
          redirect_to trip_invitation_path(:permalink => @trip, :new_duffel => "true")
        else
          flash[:notice] = "#{@trip.title} created.  Start collecting ideas!"
          redirect_to trip_path(:id => @trip)
        end
      else
        # Set redirect URL for "back" button
        if params[:back] == "research_page"
          @redirect_url = new_research_path(:idea_website => params[:idea_website], 
                                            :event_title => params[:event_title], 
                                            :jump => params[:jump],
                                            :local => params[:local],
                        										:event_code => params[:event_code],
                        										:trip_code => params[:trip_code],
                        										:idea_phone => params[:idea_phone],
                        										:idea_address => params[:idea_address],
                        										:selection => params[:selection],
                        										:type => params[:type])
          
          render :action => 'new_trip_bookmarklet', :back => params[:back], 
                                   :idea_website => params[:idea_website], 
                                   :event_title => params[:event_title],
                                   :local => params[:local],
               										 :event_code => params[:event_code],
               										 :trip_code => params[:trip_code],
               										 :idea_phone => params[:idea_phone],
               										 :idea_address => params[:idea_address],
               										 :selection => params[:selection],
               										 :type => params[:type],
               										 :layout => 'researches'
        else
          @redirect_url = dashboard_url
          @new_page = true
          render :action => 'new'
        end
      end # if @trip.save
    end # if reqeust.post?
  end
  
  def show
    load_trip_and_users(params[:id], true) # fixes ticket #38
    
    # If trip not found or not active, return 404.    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil? or @trip.active == 0

    @title = @trip.title + " in " + shorten_trip_destination(@trip.destination.strip.gsub(";", " and ")) + " - Duffel Visual Trip Planner"
    @meta_description = "Personalized guide and itinerary to " + shorten_trip_destination(@trip.destination.strip.gsub(";", " and ")) + ".  Planned on Duffel Visual Trip Planner."
    @city = [] # used in trips_helper#trip_destination_in_trip_header

    ####################################
    # Check if duffel is private
    ####################################
    
    # If trip is private, check to see whether user is logged in and invited to the trip.
    if @trip.is_public == 0
      if !logged_in?
        protect
        return
      else
        unless @users.include?(current_user) or admin? # Admin privilege
          @trip = nil
          render :partial => "private_duffel", :layout => "simple_without_js" and return
          #render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
        end
      end
    end
    
    #################################
    # Check whether in itinerary view
    ################################
    if params[:view] != "map" 
      if !logged_in? or !@users.include?(current_user)
        params[:view] = "itinerary" #render whole itinerary without sidebar
      end
    end
    
    ###################################
    # Get all the cities (well, top 5 cities) for this duffel
    ###################################
    if !fragment_exist?("#{@trip.id}-trip-dest", :time_to_live => 1.week)
      @trip.destination.split(";").each_with_index do |d,i|
        @city[i] = City.find_city_country_code_by_city_country(d.strip)
        break if i == 4 # only display 5 destinations
      end
      write_fragment("#{@trip.id}-trip-dest", @city)
    else
      @city = City.new
      @city = read_fragment("#{@trip.id}-trip-dest")
    end
    
    ###################################
    # Load duffel comments count
    ###################################
    if !fragment_exist?("#{@trip.id}-comments-size", :time_to_live => 12.hours)
      @trip_comments_size = @trip.comments.size.to_s
      write_fragment("#{@trip.id}-comments-size", @trip_comments_size)
    else
      @trip_comments_size = read_fragment("#{@trip.id}-comments-size")
    end
    
    ########################################################
    # Load duffel events (ideas, transportation, and notes)
    ########################################################
    
    # fragment caching
    s = check_events_details_cache(@trip)
    @itinerary = s[0]
    @ideas_to_map = s[1]

    @list_containment = build_sortable_list_containment(@trip)
    
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'trip' } if (params[:view] != "map" and params[:view] != "itinerary") # show.html.erb 
      format.html { render :action => 'show_map', :layout => 'trip' } if params[:view] == "map" # show_map.html.erb 
      format.html { render :action => 'show_guest_view', :layout => 'trip' } if (params[:view] == "itinerary") # show_itinerary.html.erb
      format.xml  { render :xml => { :trip => @trip, :itinerary => @itinerary } }
      format.json { render :json => { :trip => @trip, :itinerary => @itinerary } }
    end
  end
  
  def print_itinerary
    load_trip_and_users(params[:permalink])
    
    # If trip not found or not active, return 404.
    if @trip.nil? or @trip.active == 0
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
    
    @title = "#{@trip.title} Printable Itinerary - Duffel Visual Trip Planner"
    #@i = 0 # count for inserting <div class="page-break"></div> every two ideas for print break
    
    # If trip is private, check to see whether user is logged in and invited to the trip.  Else, return 404.
    if @trip.is_public == 0
      if !logged_in?
        @trip = nil
        render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
      else
        unless @users.include?(current_user)
          @trip = nil
          render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
        end
      end
    end
    
    # fragment caching
    s = check_events_details_cache(@trip)
    @itinerary = s[0]
    @ideas_to_map = s[1]
  end
  
  def edit
    @title = "Duffel - Edit Trip Details"
    @trip = Trip.find_city_id_by_permalink(params[:id]) # custom SQL to find city id via permalink
    @edit_page = true
  end
  
  # Saves trip modifications.  Only trip admins are allow to modify trip, and the security logic is also in the view level.
  def update
    @trip = Trip.find_by_permalink(params[:permalink])
    
    if params[:trip][:start_date].nil? or params[:trip][:start_date].empty? or params[:trip][:end_date].nil? or params[:trip][:end_date].empty?
      @trip.duration = Trip::DURATION_FOR_NO_ITINERARY
    else
      params[:trip][:start_date] = parse_date(params[:trip][:start_date].strip)
      params[:trip][:end_date] = parse_date(params[:trip][:end_date].strip)
      
      @trip.duration = (params[:trip][:end_date] - params[:trip][:start_date]) # Duration + 1 = Number of days
    end
    
    new_cities = City.find_id_by_city_country(params[:trip][:destination])
    
    if @trip.admins.include?(current_user) or admin?
      if @trip.update_attributes(params[:trip])
        @trip.update_existing_cities(new_cities)
        flash[:notice] = "Thanks, we updated your duffel #{@trip.title}."
        redirect_to trip_path(:id => @trip)
      else
        render :action => 'edit'
      end
    end
  end
  
  # Deletes trip.  Only trip admins are allow to delete trip.
  def destroy
    @trip = Trip.find_by_permalink(params[:id]) #ticket #38
    
    if request.delete? and @trip.admins.include?(current_user)  
      trip_title = @trip.title
      @trip.destroy
      flash[:notice] = "Your duffel #{trip_title} was deleted."
      redirect_to dashboard_path
    end
  end
  
  def create_new_visitor_trip
    if request.post?
      # Create some random string as permalinks
      token = (Digest::SHA1.hexdigest( "#{Time.now.to_s.split(//).sort_by {rand}.join}" )).slice!(2..9)
      cookies[:new_visitor_trip] = token
      
      dest = params[:trip][:destination].empty? ? "San Francisco, CA, United States" : params[:trip][:destination]
      
      t = Trip.new({ :title => "My first duffel", 
                 :permalink => token,
                 :start_date => Time.now.to_date+30, 
                 :end_date => Time.now.to_date+34, 
                 :duration => 4,
                 :is_public => 1,
                 :destination => dest, 
                 :active => 0 })
      
      t.save!
      # Add to cities_trips
      t.cities << City.find_id_by_city_country(params[:trip][:destination])
      
      # Create sample note
      Notes.create_introduction_note(t.id)

      # Create sample foodanddrink
      Idea.create_idea_in_duffel("Foodanddrink", 
                                t.id, 
                                "Add restaurants and things to do", 
                                "Clip delicious images from any website, using our Clip-It bookmarker.",
                                "http://duffelup.com/site/tools", 
                                "", 
                                "", 
                                {:file_name => "http://duffelup.com/images/trip/sample_fooddrink.jpg", :content_type => "image/jpeg", :file_size => nil}, 
                                0,
                                0)
      
      #redirect_to show_new_visitor_trip_url(:id => t.permalink)
      redirect_to(steptwo_path)
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
  end
  
  def show_new_visitor_trip
    @trip = Trip.find_by_permalink(params[:id])
    
    redirect_to trip_url(:id => params[:id]) and return if @trip.active == 1
    
    # if there's no temp trip created for new user
    if new_visitor_created_trip?
      if logged_in?
        redirect_to trip_url(:id => params[:id]) and return
      end
    else
      redirect_to trip_url(:id => params[:id]) and return
    end
    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil?
    
    @title = @trip.title + " in " + shorten_trip_destination(@trip.destination.strip.gsub(";", " and ")) + " - Duffel Visual Trip Planner"
    @city = []
    @user = User.new
    
    ###################################
    # Get all the cities (well, top 5 cities) for this duffel
    ###################################
    if !fragment_exist?("#{@trip.id}-trip-dest", :time_to_live => 1.week)
      @trip.destination.split(";").each_with_index do |d,i|
        @city[i] = City.find_city_country_code_by_city_country(d.strip)
        break if i == 4 # only display 5 destinations
      end
      write_fragment("#{@trip.id}-trip-dest", @city)
    else
      @city = City.new
      @city = read_fragment("#{@trip.id}-trip-dest")
    end
    
    ###################################
    # Load duffel comments count
    ###################################
    @trip_comments_size = "0"
    
    ########################################################
    # Load duffel events (ideas, transportation, and notes)
    ########################################################
    
    # fragment caching
    s = check_events_details_cache(@trip)
    @itinerary = s[0]
    @ideas_to_map = s[1]

    @list_containment = build_sortable_list_containment(@trip)
    
    respond_to do |format|
      format.html { render :action => 'show_new_visitor_trip', :layout => 'trip_new_visitor' } if params[:view] != "map" # show.html.erb 
      format.html { render :action => 'show_map', :layout => 'trip_new_visitor' } if params[:view] == "map" # show_map.html.erb 
    end
  end
  
  def get_deals
    trip = Trip.find_by_permalink(params[:permalink])
    d = trip.destination.split(";").first
    city = City.find_city_country_code_by_city_country(d.strip)
    
    ####################################
    # Load Kayak Flights / BookingBuddy
    ####################################
    
    if !city.nil?
      if !fragment_exist?("#{city.id}-deals-footer", :time_to_live => 6.hours)
        remote_ip = request.remote_ip
        onclick_analytics = "pageTracker._trackEvent('BookingBuddy', 'click', 'from_trip_planning_footer');"
        @deals_feed = ""
        request_url = "http://deals.bookingbuddy.com/delivery/deliver?ip_address=#{remote_ip}&publisher_id=92&no_ads=6&placement=trip_planning_footer&multiple=1&auto_backfill=1&lat=#{city.latitude}&lon=#{city.longitude}&radius=30"
        request_url = request_url + "&test=1" if "production" != RAILS_ENV

        doc = WebApp.consume_xml_from_url(request_url)
      
        (doc/:Deal).each do |deal|
          @deals_feed = @deals_feed + "<li>"
          @deals_feed = @deals_feed + "<span class=\"price\"><a target=\"_blank\" onclick=\"#{onclick_analytics}\" href=\"#{deal.at('URL').innerHTML}\">#{deal.at('Price').innerHTML}</a></span>"
          @deals_feed = @deals_feed + "<a target=\"_blank\" onclick=\"#{onclick_analytics}\" href=\"#{deal.at('URL').innerHTML}\">#{deal.at('Title').innerHTML}</a>"
          @deals_feed = @deals_feed + "<span class=\"advertiser\"><a target=\"_blank\" onclick=\"#{onclick_analytics}\" href=\"#{deal.at('URL').innerHTML}\">#{deal.at('AdvertiserName').innerHTML}</a></span>"
          @deals_feed = @deals_feed + "</li>"
        end
        
        write_fragment("#{city.id}-deals-footer", @deals_feed)
      else
        @deals_feed = read_fragment("#{city.id}-deals-footer")
      end
    else
      @deals_feed = "<p style=\"margin-top:10px;font-size:13px;\">We did not find any travel deals for this destination. :-(</p>"
    end
    
    respond_to do |format| 
      format.js do 
        render :update do |page|
          page.replace_html "deals_feed", @deals_feed
        end
      end
    end
      
      # Check Kayak.com/rss for flights
      # if !current_user.home_airport_code.nil? and !current_user.home_airport_code.blank?
      #         tm = @trip.start_date.nil? ? "" : @trip.start_date.year.to_s + @trip.start_date.month.to_s
      #         home = Iconv.iconv('ascii//translit', 'utf-8', current_user.home_airport_code).to_s.gsub(/\W/, '')
      #       
      #         if !@trip.start_date.nil? and !@trip.end_date.nil?
      #           d1 = @trip.start_date.strftime("%m/%d/%Y")
      #           d2 = @trip.end_date.strftime("%m/%d/%Y")
      #         end
      #       
      #         if !@trip.attribute_present?(:airport_code) or @trip.airport_code.nil? # if airport_code is nil or not present
      #           # don't display kayak bar
      #           @rss = nil
      #           #@rss = "<a href=\"http://www.tkqlhce.com/click-3434717-10638698\" target=\"_blank\" onClick=\"pageTracker._trackEvent('FlightBar', 'click');\">$10 off your next flight ticket to anywhere in the U.S.! Coupon Code: USFLY10</a><img src=\"http://www.awltovhc.com/image-3434717-10638698\" width=\"1\" height=\"1\" border=\"0\"/>"
      #         else # use airport-to-airport feed
      #           kayak_request = "http://www.kayak.com/h/rss/fare?code=" + home + "&dest=" + @trip.airport_code.to_s + "&mc=USD&tm=" + tm.to_s
      #           kayak_air_search = "http://www.kayak.com/s/search/air?ai=duffelup&l1=" + home + "&l2=" + @trip.airport_code.to_s + "&d1=" + d1.to_s + "&d2=" + d2.to_s
      #           r = WebApp.consume_rss_feed(kayak_request)
      #         end 
      #       
      #         # Take out the dates from Kayak's response
      #         if !r.nil? and !r.items.first.nil?
      #           @rss = r.items.first.title.gsub(/(^.+\$[^\s]+).+\s+(on\s+.+)$/, "\\1 \\2") #take out the dates
      #           @rss = "<a href=\"" + kayak_air_search + "\" target=\"_blank\" onClick=\"pageTracker._trackEvent('KayakBar', 'click');\">Kayak.com suggests " + @rss + "</a>"
      #         else
      #           # don't display kayak bar
      #           @rss = nil
      #           #@rss = "<a href=\"http://www.tkqlhce.com/click-3434717-10638698\" target=\"_blank\" onClick=\"pageTracker._trackEvent('FlightBar', 'click');\">$10 off your next flight ticket to anywhere in the U.S.! Coupon Code: USFLY10</a><img src=\"http://www.awltovhc.com/image-3434717-10638698\" width=\"1\" height=\"1\" border=\"0\"/>"
      #         end
      #       else
      #         #@rss = "<a href=\"http://www.tkqlhce.com/click-3434717-10638698\" target=\"_blank\" onClick=\"pageTracker._trackEvent('FlightBar', 'click');\">$10 off your next flight ticket to anywhere in the U.S.! Coupon Code: USFLY10</a><img src=\"http://www.awltovhc.com/image-3434717-10638698\" width=\"1\" height=\"1\" border=\"0\"/>"
      #         @rss = "Please <a href=\"/user/edit\">update your profile</a> so we can recommend flights to you."
      #       end 
  end
  
  def share
    @trip = Trip.find_by_permalink(params[:permalink])
    @fb_login_button_url = "/users/link_user_accounts?redirect=#{trip_path(:id => @trip)}"
    
    if @trip.is_public == 1
      # Setup for Fb stream
      action = WebApp.setup_fb_action_links(@trip, trip_url(:id => @trip))
      attachment = WebApp.setup_fb_trip_attachments(@trip, trip_url(:id => @trip))
    
      @fb_onclick_share = "FB.Connect.streamPublish(
                                    'I am planning a trip to #{shorten_trip_destination(@trip.destination)} on Duffel.  Any recommendations on restaurants or activities?', 
                                    #{attachment}, 
                                    #{action}, 
                                    '', 
                                    'Share your duffel with friends', 
                                    null, 
                                    false, 
                                    '');return false;"
                                    
     # Setup for Twitter stream
     url = trip_url(:id => @trip)
     short_url = WebApp.shorten_url(url)
     @tweet = "I am planning a trip to #{shorten_trip_destination(@trip.destination)} using Duffel visual planner. " + short_url + " %40duffelup"
    end
    
    render :layout => 'ibox_ideas'
  end
  
  private
  
  def load_trip_and_users(trip_perma, airport_code=false)
    @admins = []
    @users = User.new # Fragment Cache Patch: For some weird reason, reading fragment into this variable doesn't work unless initialized

    if airport_code
      @trip = Trip.find_airport_codes_by_permalink(trip_perma)
    else
      @trip = Trip.find_by_permalink(trip_perma)
    end
    
    # If trip not found or not active, return 404.
    if @trip.nil? or @trip.active == 0
      return
    end
    
    if !fragment_exist?("#{@trip.id}-users", :time_to_live => 1.day)
      @users = User.load_trip_users(@trip.id)
      write_fragment("#{@trip.id}-users", @users)
    else
      @users = read_fragment("#{@trip.id}-users")
    end
    
    # Get all admin users
    @users.each do |u|
      if u.user_type == Invitation::USER_TYPE_ADMIN.to_s
        @admins << u
      end
    end
    
  rescue RuntimeError
    logger.error("ERROR: RuntimeError in Trip Controller - Trying to access invalid trip with id = "+trip_perma.to_s)
  end

  # This method is a monkey patch for calendar_date_select's funky behaviors
  def parse_date(date)
    a_date = date.split('/')
    
    if a_date[2].length == 2 # if year only has two digits
      if a_date[2].to_i >= 90 # if year is between 99 and 90 (1990 or later)
        a_date[2] = (a_date[2].to_i + 1900).to_s
      else # if year is less than 90 (b/t 2089 and 2000)
        a_date[2] = (a_date[2].to_i + 2000).to_s
      end
    end
    
    new_date = a_date.join('/') 
    return Date.parse(new_date)
    
  rescue
    logger.error(date)
  end
  
  def clear_trip_and_events_cache
    expire_fragment "#{@trip.id}-events-details"
    expire_fragment "#{@trip.id}-mappable-ideas"
    expire_fragment "#{@trip.id}-trip-dest"
  end
  
  def check_events_details_cache(trip)
    # Fragment Cache Patch: For some weird reason, reading fragment into these variables doesn't work unless initialized
    itinerary = Event.new
    mappables = Event.new
    
    # if !fragment_exist?("#{trip.id}-events-details", :time_to_live => 1.day) or !fragment_exist?("#{trip.id}-mappable-ideas", :time_to_live => 1.day)
      itinerary = trip.events_details
      mappables = trip.mappable_ideas
    #   write_fragment("#{trip.id}-events-details", itinerary)
    #   write_fragment("#{trip.id}-mappable-ideas", mappables)
    # else
    #   itinerary = read_fragment("#{trip.id}-events-details")
    #   mappables = read_fragment("#{trip.id}-mappable-ideas")
    # end
    
    return itinerary, mappables
  end
end
