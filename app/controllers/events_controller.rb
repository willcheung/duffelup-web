class EventsController < ApplicationController
  layout "ibox_ideas"
  
  before_filter :protect, :only => [:new, :edit, :destroy, :order_itinerary]
  before_filter :load_trip_and_users, :except => [:load_trip_and_users, :show_detail, :check_events_details_cache, :new]
  before_filter :is_user_invited_to_trip, :except => [:load_trip_and_users, :show_detail, :show, :clear_events_cache, :check_events_details_cache, :new, :order_itinerary]
  after_filter :clear_events_cache, :only => [:create, :update, :destroy, :order_itinerary]
  
  def new
    @event = Event.new
    @trip = Trip.find_by_permalink(params[:permalink])
    @split_dest = @trip.destination.split(";").first # get first destination; might want to expand to multiple destinations later
    
    if params[:idea_type] == "activity"
      @label = "Add Activity"
    elsif params[:idea_type] == "hotel"
      @label = "Add Lodging"
    elsif params[:idea_type] === "foodanddrink"
      @label = "Add Food &amp; Drink"
    end
    
    respond_to do |format|
      if params[:idea_type] == "activity"
        if !fragment_exist?("viator-trip-#{@split_dest}", :time_to_live => 1.week)
          @viators = ViatorEvent.search(@split_dest)
          write_fragment("viator-trip-#{@split_dest}", @viators)
        else
          @viators = ViatorEvent.new
          @viators = read_fragment("viator-trip-#{@split_dest}")
        end
        
        format.html { render :action => "new", :view => params[:view] }
      elsif params[:idea_type] == "hotel"
        cities = City.find_id_by_city_country(@split_dest)
       
        if !cities[0].nil?
          if !fragment_exist?("#{cities[0].id}-splendia-hotels", :time_to_live => 1.week)
            @splendia_hotels = SplendiaHotel.get_hotel_by_lat_lng(cities[0].latitude, cities[0].longitude)
            write_fragment("#{cities[0].id}-splendia-hotels", @splendia_hotels)
          else
            @splendia_hotels = SplendiaHotel.new
            @splendia_hotels = read_fragment("#{cities[0].id}-splendia-hotels")
          end
        else
          @splendia_hotels = []
        end
        
        format.html { render :action => "new", :view => params[:view] }
      elsif params[:idea_type] == "transportation" or params[:idea_type] == "notes"
        format.html { render :action => "new_#{params[:idea_type]}", :view => params[:view] }
      else
        format.html { render :action => "new", :view => params[:view] }
      end
    end
  end
  
  def create
    case params[:idea_type]
    when 'activity'
      @activity = Activity.new(params[:activity])
      @event = @activity.create_event(params[:event])
      @event.created_by = current_user.id
      @event.bookmarklet = 0
      @event = @activity.create_activity(@event, @trip, current_user)
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_ACTIVITY, @trip)
      
      respond_to do |format|
        if @activity.save
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }  
        end  
      end
      
    when 'viator'
      
      ViatorEvent.insert_recommendation(@trip.destination.split(";").first, @trip.id, params[:event][:viator]) unless params[:event].nil?
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_ACTIVITY, @trip)
      
      respond_to do |format|
        format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }  
      end
    
    when 'splendia'
      added_hotels = []
      
      cities = City.find_id_by_city_country(@trip.destination.split(";").first)
      
      if !fragment_exist?("#{cities[0].id}-splendia-hotels", :time_to_live => 1.week)
        splendia_hotels = SplendiaHotel.get_hotel_by_lat_lng(cities[0].latitude, cities[0].longitude)
        write_fragment("#{cities[0].id}-splendia-hotels", splendia_hotels)
      else
        splendia_hotels = SplendiaHotel.new
        splendia_hotels = read_fragment("#{cities[0].id}-splendia-hotels")
      end
      
      splendia_hotels.each do |h|
        added_hotels << h if (params[:event][:splendia_hotel_ids]).include?(h.hotel_id.to_s)
      end
      
      SplendiaHotel.insert_recommendation(added_hotels, @trip.id, @trip.start_date, @trip.end_date, nil)
      
      respond_to do |format|
        format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }  
      end
      
    when 'hotel'
      @hotel = Hotel.new(params[:hotel])
      @event = @hotel.create_event(params[:event])
      @event.created_by = current_user.id
      @event.bookmarklet = 0
      @event = @hotel.create_hotel(@event, @trip, current_user)
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_LODGING, @trip)
      
      respond_to do |format|
        if @hotel.save  
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }  
        end  
      end
    
    when 'foodanddrink'
      @foodanddrink = Foodanddrink.new(params[:foodanddrink])
      @event = @foodanddrink.create_event(params[:event])
      @event.created_by = current_user.id
      @event.bookmarklet = 0
      @event = @foodanddrink.create_foodanddrink(@event, @trip, current_user)
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_FOODANDDRINK, @trip)
      
      respond_to do |format|
        if @foodanddrink.save 
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }  
        end  
      end
      
    when 'transportation'
      @transportation = Transportation.new(params[:transportation])
      @event = @transportation.create_event(params[:event])
      @event.created_by = current_user.id
      @event.bookmarklet = -1
      @event = @transportation.create_transportation(@event, @trip)
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_TRANSPORTATION, @trip)
      
      respond_to do |format|
        if @transportation.save
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
        end
      end
      
    when 'notes'
      @notes = Notes.new(params[:notes])
      @event = @notes.create_event(params[:event])
      @event.created_by = current_user.id
      @event.bookmarklet = -1
      @event = @notes.create_notes(@event, @trip)
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_NOTES, @trip)
      
      respond_to do |format|
        if @notes.save 
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
        end
      end
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    
    if @trip.events.include?(@event)
      if @event.eventable_type == "Hotel" or @event.eventable_type == "Activity" or @event.eventable_type == "Foodanddrink"
        @header = "Editing #{@event.title}"
        @idea = Idea.find(@event.eventable_id)
      elsif @event.eventable_type == "Transportation"
        @title = "Duffel - Edit Transportation"
        @header = "Editing Transportation"
        @transportation = Transportation.find(@event.eventable_id)
      elsif @event.eventable_type == "Notes"
        @title = "Duffel - Edit Note"
        @header = "Editing Notes"
        @notes = Notes.find(@event.eventable_id)
      end
    else
      redirect_to(:controller => 'site', :action => 'permission_error')
    end
    
  rescue ActiveRecord::RecordNotFound
    logger.error("ERROR: Trying to access invalid event id = " + params[:id].to_s)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  # Updates the both Event and Idea/Transportation/Notes models.  
  # Idea model's title is copied from Event model.
  def update
    @event = Event.find(params[:id])
    
    if @event.eventable_type == "Activity" or @event.eventable_type == "Hotel" or @event.eventable_type == "Foodanddrink"
      
      @idea = Idea.find(@event.eventable_id)
      
      respond_to do |format|
        if @event.update_attributes(params[:event]) and @idea.update_attributes(params[:idea])
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
          format.js
        else
          flash[:error] = "There seems to be an error updating the note."
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
        end
      end
    elsif @event.eventable_type == "Transportation"
      @transportation = Transportation.find(@event.eventable_id)
      @event.title = CGI::escapeHTML(params[:transportation][:from]) + " &rarr; " + CGI::escapeHTML(params[:transportation][:to])
      
      respond_to do |format|
        if @transportation.update_attributes(params[:transportation]) and @event.update_attributes(params[:event])
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
          format.js
        else
          flash[:error] = "There seems to be an error updating the transportation."
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
        end
      end
    elsif @event.eventable_type == "Notes"
      @notes = Notes.find(@event.eventable_id)
      tmp_notes = Notes.new(params[:notes])
      @event = tmp_notes.create_notes(@event, @trip)
      
      respond_to do |format|
        if @event.update_attributes(params[:event]) and @notes.update_attributes(params[:notes])
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
          format.js
        else
          flash[:error] = "There seems to be an error updating your note."
          format.html { redirect_to trip_path(:id => @trip, :view => params[:view]) }
        end
      end
    end
  end
  
  def show
    e = Event.find(params[:id])
    @title = "Duffel - " + e.title

    case e.eventable_type
    when "Hotel", "Activity", "Foodanddrink"
      @event = Event.find_ideas(@trip.id, e.id).first
    when "Transportation"
      @event = Event.find_transportations(@trip.id, e.id).first
    when "Notes"
      @event = Event.find_notes(@trip.id, e.id).first
    when "CheckIn"
      @event = Event.find_check_ins(@trip.id, e.id).first
    end
    
    respond_to do |format|
      format.html
      format.js 
    end

    rescue ActiveRecord::RecordNotFound
      logger.error("ERROR: Trying to access invalid event id = " + params[:id].to_s)
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    @itinerary = @trip.events_details
    @list_containment = build_sortable_list_containment(@trip)
    respond_to do |format|
      format.html { redirect_to trip_path(:id => @trip) }
      format.js 
    end
  end
  
  def order_itinerary
    if request.xhr?
      if params['board']
        Event.update_itinerary(@trip.id, params['board'], 0.to_s)
      else
        (@trip.duration+1).times do |i|
          if params['itinerary_list_'+(i+1).to_s]
            Event.update_itinerary(@trip.id, params['itinerary_list_'+(i+1).to_s], (i+1).to_s)
            @day = i
            break
          end # if params['itinerary_list_']
        end # @trip.duration.times
      end # if params['board']
      
      # clear all events cache
      clear_events_cache
      
      respond_to do |format|
        format.js { render :nothing => true }
      end
    end
  end
  
  private 
  
  def load_trip_and_users
    @trip = Trip.find_by_permalink(params[:permalink])
    @users = User.new
    
    if !fragment_exist?("#{@trip.id}-users", :time_to_live => 12.hours)
      @users = User.load_trip_users(@trip.id)
      write_fragment("#{@trip.id}-users", @users)
    else
      @users = read_fragment("#{@trip.id}-users")
    end
  end
  
  def clear_events_cache
    expire_fragment "#{@trip.id}-events-details"
    expire_fragment "#{@trip.id}-mappable-ideas"
  end
  
  def check_events_details_cache(trip)
    # Fragment Cache Patch: For some weird reason, reading fragment into these variables doesn't work unless initialized
    itinerary = Event.new
    mappables = Event.new
    
    if !fragment_exist?("#{trip.id}-events-details", :time_to_live => 1.day) or !fragment_exist?("#{trip.id}-mappable-ideas", :time_to_live => 1.day)
      itinerary = trip.events_details
      mappables = trip.mappable_ideas
      write_fragment("#{trip.id}-events-details", itinerary)
      write_fragment("#{trip.id}-mappable-ideas", mappables)
    else
      itinerary = read_fragment("#{trip.id}-events-details")
      mappables = read_fragment("#{trip.id}-mappable-ideas")
    end
    
    return itinerary
  end
  
end
