class SiteController < ApplicationController
  layout "simple_without_js", :except => [:index, :tutorial, :tutorial_bookmarklet, :tutorial_overview, :partner_frame, :tour, :partner_header, :business_overview, :business_features, :ian_header]
  
  before_filter :protect, :only => [:feedback]

  def index
    @title = "DuffelUp.com Trip Planner - Organize Your Travel Itinerary"
    
    if logged_in?
      redirect_to dashboard_path
    end
  end

  def about
    @title = "About Us - DuffelUp.com Trip Planner"
    @sub_title = "About Us"
  end
  
  def jobs
    @title = "Jobs at DuffelUp.com Visual Trip Planner"
    @sub_title = "Jobs"
  end
  
  def tour
    @title = "DuffelUp.com - Take the Tour"
  end
  
  def search
    @title = "Search Cities and Trips on DuffelUp.com Trip Planner"
    @sub_title = "Search"
    return if params[:q].nil?
    
    unless params[:q].empty?
      @cities_search_result = City.search(params[:q], 8)
      @duffels_search_result = Trip.search(params[:q], 5)
      
      if !@cities_search_result.empty? and @cities_search_result[0].rank == 1
        if @cities_search_result[0].country_code == "US" or @cities_search_result[0].country_code == "CA"
					redirect_to na_city_url(:country_code => @cities_search_result[0].country_code, :region => @cities_search_result[0].region, :city => city_name_to_url(@cities_search_result[0].city)) and return
				else
					redirect_to city_url(:country_code => @cities_search_result[0].country_code, :city => city_name_to_url(@cities_search_result[0].city)) and return
				end
			end
      
      respond_to do |format|
        format.html { render :layout => 'simple' }
      end
    end
  end

  def tools
    @title = "DuffelUp.com - Add to Duffel Bookmarklet"
    @sub_title = "\"Add to Duffel\" Bookmarklet"
    
    if logged_in?
      @key = ApiKey.check_api_key(current_user, "widget")
    else
      @key = ApiKey.check_api_key(User.find_by_username("duffel_demo"), "widget")
    end
    
    # <a href="" onclick="javascript: (function(){EN_CLIP_HOST='http://duffelup.com';EN_CLIP_URL='http://some_url';EN_CLIP_TITLE='some title';EN_CLIP_NOTES='some notes';EN_CLIP_ADDRESS='some address';EN_CLIP_PHONE='some phone';var a=document.createElement('SCRIPT');a.type='text/javascript';a.src='http://sap1ens.ru/duffel/bookmark.js?'+(new Date).getTime()/1E5;document.getElementsByTagName('head')[0].appendChild(a)})(); return false;">Add me with predefined variables</a>
  end

  def help
    @title = "DuffelUp.com - Help"
    @sub_title = "Help"
  end
  
  def terms_of_use
    @title = "DuffelUp.com - Terms of Use"
    @sub_title = "Terms of Use"
  end
  
  def privacy_policy
    @title = "DuffelUp.com - Privacy Policy"
    @sub_title = "Privacy Policy"
  end
  
  def feedback
    @title = "DuffelUp.com - Feedback"
    
    if request.post?
      Postoffice.deliver_feedback(params[:feedback][:body], current_user.username, current_user.email)
      flash[:notice] = "Thank you for contacting us."
      redirect_back_or_default(dashboard_path, params[:redirect])
    end
  end
  
  def contact
    @title = "DuffelUp.com - Contact Us"
    @sub_title = "Contact Us"
  end
  
  def press
    @title = "DuffelUp.com - Press"
    @sub_title = "Press Kit"
  end
  
  def tutorial
  end
  
  def tutorial_bookmarklet
  end
  
  def tutorial_overview
  end
  
  def partner_header
    # Used by Viator
  end
  
  def ian_header
  end
  
  def viator_activities
    redirect_to('http://www.partner.viator.com/en/7101/')
  end
  
  def splendia_hotels
    @title = "DuffelUp.com - Find the perfect luxury hotel for your vacation"
    
    if params[:hotel_id]
      @iframe_height = "2400"
      @iframe_url = "http://pl.splendia.com/en/hotel/?partnerid=A434&lang=EN&hotel_id=" + params[:hotel_id].to_s
      
      if !params[:datestart].nil? and !params[:dateend].nil?
        @iframe_url = @iframe_url + "&datestart=" + params[:datestart] + "&dateend=" + params[:dateend]
      end
    else
      # default width is 720px
      @iframe_height = "720"
      @iframe_url = "http://pl.splendia.com/?partnerid=A434&lang=EN"
    end

  end
  
  def partner_frame
    if params[:p] == "activities"
      @partner_url = ViatorEvent::ORIGINAL_URL + decode64(params[:key].to_s)
      @title = "Duffel Partner - Stuff To Do, Tours, and Activities"
    elsif params[:p] == "hotels"
      @partner_url = Hotels::ORIGINAL_URL + decode64(params[:key].to_s)
      @title = "Duffel Partner - Places to Stay, Car Rentals, Flights, and Packages"
    elsif params[:p] == "tablet"
      @partner_url = "http://www.tablethotels.com/?affiliateId=1431"
      @title = "Duffel Partner - Boutique and Luxury Hotels"
    else
      redirect_to :controller => :site, :action => :index
    end
  end
  
  def browser_error
    @title = "DuffelUp.com - Your browser is not supported."
    @meta_description = "Browser Error"
  end
  
  def permission_error
    @title = "DuffelUp.com - Permission Denied."
    @meta_description = "Permission Denied"
  end
end