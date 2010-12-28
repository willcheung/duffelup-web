require 'base64'

class ResearchesController < ApplicationController
  before_filter :protect_bookmarklet, :only => [:new]
  after_filter :clear_events_details_cache, :only => :create

  # Old
  # javascript:location.href='http://localhost:3000/research/new?idea_website='+encodeURIComponent(location.href)+'&event_title='+encodeURIComponent(document.title)
  
  # New (FF and Safari)
  # javascript:(function(){f='http://localhost:3000/research/new?idea_website='+encodeURIComponent(window.location.href)+'&event_title='+encodeURIComponent(document.title)+'&';a=function(){if(!window.open(f+'jump=doclose','duffelbookmarklet','location=yes,links=no,scrollbars=no,toolbar=no,width=650,height=550'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()
  # IE
  # javascript:(function(){location.href='http://localhost:3000/research/new?idea_website='+encodeURIComponent(window.location.href)+'&event_title='+encodeURIComponent(document.title)+'&jump=yes'})()
  
  ##### Parameters ######
  # idea_website
  # event_title
  # jump (if = "doclose", then close pop-up window after save; if ="yes", then go back to URL)
  # local (if "true", copy within Duffel site)
  ##### if local == true ######
  # event (event_id in Base64 format)
  # trip (trip_id in Base64 format)
  # idea_phone
  # idea_address
  # type
  
  def new
    @title = "Duffel - Add an Idea"
    @trips = get_trips
    
    # If request is originated from Duffel site (which means it's a "copy" request)
    if params[:local] == "true"
      @event_id = Base64.decode64(params[:event_code])
      @trip_permalink = Base64.decode64(params[:trip_code])
      event = Event.find_by_id(@event_id)
      @event_note_value = event.note
    elsif params[:selection]
      @event_note_value = params[:selection]
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    eventable_type = params[:event][:eventable_type]
    trip_id = params[:event][:trip_id]
    cookies[:default_trip] = params[:event][:trip_id] # Remembers the Trip user last selected
    
     # delete protected attributes b/c they can't be saved from the form
    params[:event].delete("eventable_type")
    params[:event].delete("trip_id")
    
    @trip = Trip.find(trip_id)
    
    source_trip = Trip.find_by_permalink(params[:trip_permalink]) if params[:local] == "true"
    
    if eventable_type == "Activity" or eventable_type == "Hotel" or eventable_type == "Foodanddrink"
      
      @idea = Object.const_get(eventable_type).new(params[:idea])
      @event = @idea.create_event(params[:event])
      @event.created_by = current_user.id
      
      # Clip photo
      unless params[:nophoto] == "on"
        @event.photo_file_name = params[:actImg]
        @event.photo_content_type = "image/jpeg" # just for photo type validation
      end

      # set attributes and protected attributes
      @event.trip_id = trip_id
      @event.bookmarklet = 1
      @idea.type = eventable_type
      
      if eventable_type == "Activity"
        ###################################
        # publish news to activities feed
        ###################################
        if params[:local] == "true"
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::COPY_ACTIVITY, @trip, "<a href=\"http://duffelup.com/trips/#{source_trip.permalink}\">#{source_trip.title}</a>")
        else
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_ACTIVITY_CLIPIT, @trip)
        end
      elsif eventable_type == "Hotel"
        ###################################
        # publish news to activities feed
        ###################################
        if params[:local] == "true"
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::COPY_LODGING, @trip, "<a href=\"http://duffelup.com/trips/#{source_trip.permalink}\">#{source_trip.title}</a>")
        else
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_LODGING_CLIPIT, @trip)
        end
      elsif eventable_type == "Foodanddrink"
        ###################################
        # publish news to activities feed
        ###################################
        if params[:local] == "true"
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::COPY_FOODANDDRINK, @trip, "<a href=\"http://duffelup.com/trips/#{source_trip.permalink}\">#{source_trip.title}</a>")
        else
          ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_FOODANDDRINK_CLIPIT, @trip)
        end
      end
    elsif eventable_type == "Transportation"
      @idea = Transportation.new(params[:transportation])
      @event = @idea.create_event(params[:event])
      @event.note = params[:event][:trans_note] # replaces the original note
      @event.created_by = current_user.id
      @event.title = @idea.from + " &rarr; " + @idea.to
      
      # set attributes and protected attributes
      @event.trip_id = trip_id
      @event.bookmarklet = 1
      
      ###################################
      # publish news to activities feed
      ###################################
      if params[:local] == "true"
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::COPY_TRANSPORTATION, @trip, "<a href=\"http://duffelup.com/trips/#{source_trip.permalink}\">#{source_trip.title}</a>")
      else
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_TRANSPORTATION_CLIPIT, @trip)
      end
    elsif eventable_type == "Notes"
      @idea = Notes.new(params[:notes])
      @event = @idea.create_event(params[:event])
      @event.title = params[:notes][:title]
      @event.created_by = current_user.id
      
      # set attributes and protected attributes
      @event.trip_id = trip_id
      @event.bookmarklet = 1
      
      ###################################
      # publish news to activities feed
      ###################################
      if params[:local] == "true"
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::COPY_NOTES, @trip, "<a href=\"http://duffelup.com/trips/#{source_trip.permalink}\">#{source_trip.title}</a>")
      else
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_NOTES_CLIPIT, @trip)
      end
    end

    respond_to do |format|
      if @idea.save 
        # When jump=yes or undefined, it redirects back to duffeled website.
        if params[:jump] == "doclose"
          format.html { render :inline => "<p style=\"text-align:center;padding-top:20px;font-size:20px\">Saved!</p><script type=\"text/javascript\">setTimeout(\'window.location.href=\"/close.html\"\',600);</script>", :layout => true }
        elsif params[:jump] == "doclosepopup"
          format.html { render :inline => "<p style=\"text-align:center;padding-top:20px;font-size:20px\">Saved!</p><script type=\"text/javascript\">setTimeout(\'window.close();\',600);</script>", :layout => true }
        else
          unless params[:trip_permalink].nil?
            format.html { redirect_to trip_url(:id => params[:trip_permalink]) }
          else
            format.html { redirect_to params[:idea][:website] }  
          end
        end
        
      else 
        @trips = get_trips
        format.html { render :action => 'new' }  
      end  
    end
  end
  
  def show
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  def edit
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  private
  
  def protect_bookmarklet
    unless logged_in?
      session[:return_to] = request.request_uri
      params = CGI.parse(URI.parse("http://duffelup.com" + request.request_uri).query)
      
      flash[:notice] = "Please log in first"
      redirect_to bookmarklet_login_url(:pid => params["pid"])
      return false
    end
  end
  
  def get_trips
    planned_trips = []
    no_date_trips = []
    past_trips = []
    
    current_user.trips.each do |trip|
      if trip.end_date.nil? or trip.start_date.nil?
        no_date_trips << trip 
      elsif trip.end_date < Date.today
        past_trips << trip 
      else
        planned_trips << trip 
      end
    end
    
    return (planned_trips << no_date_trips).flatten
    
  end
  
  def clear_events_details_cache
    expire_fragment "#{@event.trip_id}-events-details"
  end
  
end
