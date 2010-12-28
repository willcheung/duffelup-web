class SiteController < ApplicationController
  layout "simple_without_js", :except => [:index, :tutorial, :tutorial_bookmarklet, :tutorial_overview, :partner_frame, :tour, :partner_header, :business_overview, :business_features, :ian_header]
  
  before_filter :protect, :only => [:feedback]

  def index
    @title = "Duffel - Visual Trip Planner - Organize Your Travel Itinerary"
    
    if logged_in?
      redirect_to dashboard_path
    end
    
    @user = User.new
  end

  def about
    @title = "About Us - Duffel Visual Trip Planner"
    @sub_title = "About Us"
  end
  
  def jobs
    @title = "Jobs at Duffel - Visual Trip Planner"
    @sub_title = "Jobs"
  end
  
  def tour
    @title = "Duffel - Take the Tour"
  end
  
  def search
    @title = "Search Cities and Trips on Duffel - Visual Bookmarker and Trip Planner"
    @sub_title = "Search"
    return if params[:q].nil?
    
    unless params[:q].empty?
      @cities_search_result = City.search(params[:q], 8)
      @duffels_search_result = Trip.search(params[:q], 5)
      @duffelers = User.search(params[:q], params[:page], 12)
      
      respond_to do |format|
        format.html { render :layout => 'simple' }
      end
    end
  end

  def tools
    @title = "Duffel - Clip-It Bookmarklet and Widgets"
    @sub_title = "Clip-It Bookmarker and Tools"
    
    if logged_in?
      @key = ApiKey.check_api_key(current_user, "widget")
    else
      @key = ApiKey.check_api_key(User.find_by_username("duffel_demo"), "widget")
    end
    
    # <a href="" onclick="javascript: (function(){EN_CLIP_HOST='http://duffelup.com';EN_CLIP_URL='http://some_url';EN_CLIP_TITLE='some title';EN_CLIP_NOTES='some notes';EN_CLIP_ADDRESS='some address';EN_CLIP_PHONE='some phone';var a=document.createElement('SCRIPT');a.type='text/javascript';a.src='http://sap1ens.ru/duffel/bookmark.js?'+(new Date).getTime()/1E5;document.getElementsByTagName('head')[0].appendChild(a)})(); return false;">Add me with predefined variables</a>
  end

  def help
    @title = "Duffel - Help"
    @sub_title = "Help"
  end
  
  def terms_of_use
    @title = "Duffel - Terms of Use"
    @sub_title = "Terms of Use"
  end
  
  def privacy_policy
    @title = "Duffel - Privacy Policy"
    @sub_title = "Privacy Policy"
  end
  
  def feedback
    @title = "Duffel - Feedback"
    
    if request.post?
      Postoffice.deliver_feedback(params[:feedback][:body], current_user.username, current_user.email)
      flash[:notice] = "Thank you for contacting us."
      redirect_back_or_default(dashboard_path, params[:redirect])
    end
  end
  
  def contact
    @title = "Duffel - Contact Us"
    @sub_title = "Contact Us"
  end
  
  def press
    @title = "Duffel - Press"
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
    @title = "Duffel - Find the perfect luxury hotel for your vacation"
    # default width is 720px
    @frame_width = "720"
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
      redirect_to :controller => :site, :action => :partners
    end
  end
  
  def partners
    @title = "Partners - Duffel - Visual Trip Planner"
    @sub_title = "Duffel Partners"
    
    #Hotel Search
    #http://reserve.duffelup.com/index.jsp?cid=261673&pageName=hotSearch&submitted=true&validateDates=true&arrivalMonth=3&arrivalDay=3&departureMonth=3&departureDay=5&mode=2&numberOfRooms=1&numberOfAdults=2&numberOfChildren=0avail=true&passThrough=true&validateCity=true&city=Hoboken, NJ, United States
  
    #Air Search
    #http://reserve.duffelup.com/index.jsp?cid=261673&pageName=airSearch&submitted=true&avail=true&cabin=Y&adults=1&seniors=0&children=0&passThrough=true&showPopUp=true&tripType=R&tempDepTime=ANT&tempRetTime=ANT&isAdvancedSearch=false&destinationCity=lax&departureCity=san francisco&departureMonth=4&departureDay=4&returnMonth=4&returnDay=8
  end
  
  def browser_error
    @title = "Duffel - Your browser is not supported."
    @meta_description = "Browser Error"
  end
  
  def permission_error
    @title = "Duffel - Permission Denied."
    @meta_description = "Permission Denied"
  end
end