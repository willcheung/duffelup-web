require 'flickr_fu'

class WebappsController < ApplicationController
  include ApplicationHelper
  
  layout "simple"
  
  def flickr
    flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
    
    if request.post?
      @photos = flickr.photos.search(:tags => params[:flickr_photo][:city], :license => "4,5,6,7", :per_page => 150, :media => 'photo', :page => 1, :sort => 'interestingness-desc')
    end
    # @photos_NY = FlickrPhoto.find_by_city_id(610)
    #     @photos_SF = FlickrPhoto.find_by_city_id(609)
    #     @photos_LA =
  end
  
  def import
    @users,@not_users = [],[]
    contacts = WebApp.import_contacts(params[:email], params[:password])
    contacts.each do |contact|
      if u = User.find(:first , :conditions => "email = '#{contact[1]}'" )
        @users << u
      else
        @not_users << { :name => contact[0] , :email => contact[1] }
      end
    end
    
    respond_to do |format|
      format.js do 
        render :update do |page|
          page.remove "contact_list_form"
          page.replace_html "contact_list", :partial => "webapps/contact_list"
          page.visual_effect(:highlight, "contact_list")
        end
      end
    end
    
  rescue Contacts::AuthenticationError
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html "contact_list_error", :text => "<p><strong>&nbsp;&nbsp;Doh! Your email or password may not be correct.</strong></p>"
          page.visual_effect(:highlight, "contact_list_error", :duration => 2, :startcolor => "#ff0000")
        end
      end
    end
  end
  
  def sync_itinerary
  	load_trip_and_users(params[:permalink])
	# If trip not found or not active, return 404.
    if @trip.nil? or @trip.active == 0
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
	
    @itinerary = @trip.events_details
    @title = "Duffel - Google Calendar Sync"
	
    gc = GData.new
    if gc.login('indifferenze@gmail.com', 'indifferenze123')
      if @trip.duration !=0 
        (@trip.duration+1).times do |day|
          event_day = (@trip.start_date + day)
          default_start_time = 8 # Setting activity start time default as 8am.
          count = 0
          for event in @itinerary[day+1]
            location = ""
            website = ""
            phone = ""
            note = ""
            info = ""
            start_time = ""
            end_time = ""
            event_name = ""
            
            if event.title == nil or event.eventable_type == "Notes"
              next
            end
            
            
            if count <= 0
              start_time = "#{event_day}" + "T0" + "#{default_start_time+count}" + ":00:00"
              end_time = "#{event_day}" + "T0" "#{default_start_time+count+1}" + ":00:00" # Default activity is 1 hour.
            elsif count <= 1
              start_time = "#{event_day}" + "T0" + "#{default_start_time+count}" + ":00:00"
              end_time = "#{event_day}" + "T" + "#{default_start_time+count+1}" + ":00:00"
            else
              start_time = "#{event_day}" + "T" + "#{default_start_time+count}" + ":00:00"
              end_time = "#{event_day}" + "T" + "#{default_start_time+count+1}" + ":00:00"
            end
            
            
            if event.eventable_type == "Foodanddrink" or event.eventable_type == "Activity" or event.eventable_type == "Hotel"
              event_name = event.title
              location = event.address if not event.address.empty?
              website = event.website if not event.website.empty?
              phone = event.phone if not event.phone.empty?
              note = event.note if not event.note.empty?
              istrip = 0
            end
            if event.eventable_type == "Transportation"
              event_name = event.title
              event_name = event_name.gsub("&rarr;", "to")
              depart_loc = event.from if not event.from.empty?
              start_time = event.departure_time unless event.departure_time.nil?
              arriv_loc = event.to if not event.to.empty?
              end_time = event.arrival_time unless event.arrival_time.nil?
              note = event.note if not event.note.empty?
              start_time = start_time.gsub(" ", "T")
              end_time = end_time.gsub(" ", "T")
              istrip = 1
				    end         
            
            info = note + website + phone
            if location == ""
              location = depart_loc
            end
            
            gcevent = {
                        :title => event_name,
                        :content => info,
                        :author => 'ming.fu@gmail.com',
                        :email => 'ming.fu@gmail.com',
                        :where => location,
                        :startTime => start_time,
                        :endTime => end_time,
                      }
            gc.get_calendars()
            calendar_exists = gc.find_calendar("duffel")
            if calendar_exists
              gc.new_event(gcevent, "duffel test calendar")
              flash[:notice] = "Successfully synced events schedule to Google Calendar!"
              count += 1
            else
              flash[:notice] = "Could not find calendar: duffel on your Google Calendar!"
            end
          end
        end
      end
    else
      flash[:notice] = "Could not log into Google Calendar!"
    end
  end
  
  def load_trip_and_users(trip_perma)
    @admins = []

    @trip = Trip.find_by_permalink(trip_perma)
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
  
end