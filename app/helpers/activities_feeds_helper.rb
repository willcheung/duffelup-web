module ActivitiesFeedsHelper
  # only display feed when current_user is invited to the trip
  def display_private_duffel_feed(feed)
    return false if current_user.nil? # don't display if user is not logged in
    
    if !@users_by_trip_id.nil? and !@users_by_trip_id[feed.trip_id.to_s].nil? 
      @users_by_trip_id[feed.trip_id.to_s].each do |u| 
        if u.id == current_user.id
          return true
        end
      end
    end
    
    return false
  end
  
  # Group news feed and display feed details
  def group_activities(activities)
    grouped_activities = []
    bunch_of_json_events = [] # bunch of events in JSON format
    bunch_of_photos = [] # bunch of photo urls for photo spots (check_ins)
    names = "" # used for travelers going on the same trip
    counter = 1 # used to keep track of # of activities added
    
    return [] if activities.nil?

    activities.each_with_index do |a,i|
      previous_activity = (i == 0) ? nil : activities[i-1]
      next_activity = (i == (activities.size-1)) ? nil : activities[i+1]
      trip_url = create_url_from_trip_json(a.trip)
      
      case a.action.to_i
      when ActivitiesFeed::ADD_COMMENT
        a.content = a.actor + " commented on " + trip_url + "." 
        grouped_activities << a
      when ActivitiesFeed::ADD_FAVORITE
        a.content = a.actor + " saved " + trip_url + " as Favorites."
        grouped_activities << a
      when ActivitiesFeed::CREATE_TRIP
        a.content = a.actor + " started planning " + trip_url + ". Any recommendations?"
        grouped_activities << a
      when ActivitiesFeed::ADD_ACTIVITY
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added an activity into " + trip_url + "." : a.actor + " added " + counter.to_s + " activities into " + trip_url + "."
          
          a.content += create_events_html(bunch_of_json_events, "Activity", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::ADD_LODGING
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a lodging into " + trip_url + "." : a.actor + " added " + counter.to_s + " lodgings into " + trip_url + "." 
          
          a.content += create_events_html(bunch_of_json_events, "Lodging", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a   
        end   
      when ActivitiesFeed::ADD_FOODANDDRINK
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a food & drink into " + trip_url + "." : a.actor + " added " + counter.to_s + " food & drinks into " + trip_url + "." 
          
          a.content += create_events_html(bunch_of_json_events, "Foodanddrink", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::ADD_TRANSPORTATION
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a transportation into " + trip_url + "." : a.actor + " added " + counter.to_s + " transportations into " + trip_url + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::ADD_NOTES
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a note into " + trip_url + "." : a.actor + " added " + counter.to_s + " notes into " + trip_url + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::ADD_ACTIVITY_CLIPIT
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added an activity into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " activities into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT 
          
          a.content += create_events_html(bunch_of_json_events, "Activity", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::ADD_LODGING_CLIPIT
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a lodging into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT : a.content = a.actor + " added " + counter.to_s + " lodgings into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT 
          
          a.content += create_events_html(bunch_of_json_events, "Lodging", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::ADD_FOODANDDRINK_CLIPIT
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a food & drink into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " food & drinks into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT 
          
          a.content += create_events_html(bunch_of_json_events, "Foodanddrink", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::ADD_TRANSPORTATION_CLIPIT
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a transportation into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " transportations into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::ADD_NOTES_CLIPIT
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a note into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " notes into " + trip_url + ActivitiesFeed::CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::ADD_CHECK_IN
        bunch_of_photos << a.photo_url
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          if counter == 1
            a.content = a.actor + " added a photo spot <strong>" + a.title + "</strong> to trip " + trip_url + "."
          else
            a.content = a.actor + " added " + counter.to_s + " photo spots " " to trip " + a.trip + "."
          end
          
          # Display photos
          a.content +=  "<div id=\"photo_spot\"><ul>"
          bunch_of_photos.each do |p_url|
            a.content += "<li><div style=\"overflow:hidden\"><img src=\"#{p_url}\"/></div></li>"
          end
          a.content += "</ul></div>"
          
          counter = 1 #reset counter
          bunch_of_photos = [] #reset photos collection
          grouped_activities << a
        end
      when ActivitiesFeed::COPY_ACTIVITY
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied an activity into " + trip_url + "." : a.actor + " copied " + counter.to_s + " activities into " + trip_url + "."  
          
          a.content += create_events_html(bunch_of_json_events, "Activity", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ActivitiesFeed::COPY_LODGING
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a lodging into " + trip_url + "." : a.actor + " copied " + counter.to_s + " lodgings into " + trip_url + "."  
          
          a.content += create_events_html(bunch_of_json_events, "Lodging", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a   
        end   
      when ActivitiesFeed::COPY_FOODANDDRINK
        bunch_of_json_events << a.predicate
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a food & drink into " + trip_url + "." : a.actor + " copied " + counter.to_s + " food & drinks into " + trip_url + "."  
          
          a.content += create_events_html(bunch_of_json_events, "Foodanddrink", a.trip)
          
          bunch_of_json_events = [] #reset array
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::COPY_TRANSPORTATION
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a transportation into " + trip_url + "." : a.actor + " copied " + counter.to_s + " transportations into " + trip_url + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::COPY_NOTES
        counter += 1 if same_as_previous_activity(previous_activity, a)
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a note from into " + trip_url + "." : a.actor + " copied " + counter.to_s + " notes into " + trip_url + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ActivitiesFeed::INVITE_TO_TRIP
        a.content = a.actor + " invited " + a.predicate + " to " + trip_url + "."
        grouped_activities << a
      when ActivitiesFeed::APPROVE_FRIENDSHIP
        a.content = a.actor + " is now friends with " + a.predicate + "."
        grouped_activities << a
      when ActivitiesFeed::DEPART_FOR_TRIP
        if going_on_same_trip(previous_activity, a)
          counter = counter + 1
          if counter == 2
            names = previous_activity.actor
          else
            names = names + ", " + previous_activity.actor
          end
        end
        
        if not_going_on_same_trip(next_activity, a)
          if counter == 1
            a.content = a.actor + " is almost duffeled up for their trip " + trip_url + ". Any last minute travel tips?"
          else
            a.content = names + " and " + a.actor + " are almost duffeled up for their trip " + trip_url + ". Any last minute travel tips?"
            counter = 1
            grouped_activities << a
          end
        end
        
      when ActivitiesFeed::RETURN_FROM_TRIP
        if going_on_same_trip(previous_activity, a)
          counter = counter + 1
          if counter == 2
            names = previous_activity.actor
          else
            names = names + ", " + previous_activity.actor
          end
        end
        
        if not_going_on_same_trip(next_activity, a)
          if counter == 1
            a.content = a.actor + " just returned from their trip " + trip_url + ". They gotta post some pictures soon."
          else
            a.content = names + " and " + a.actor + " just returned from their trip " + trip_url + ". They gotta post some pictures soon."
            counter = 1
            grouped_activities << a
          end
        end
      end # end of case
    end # end of activities loop
    
    return grouped_activities
  end
  
  def same_as_previous_activity(previous_activity, this_activity)
    if previous_activity.nil?
      return false
    elsif (previous_activity.user.id == this_activity.user.id and 
          previous_activity.action == this_activity.action and
          previous_activity.trip_id == this_activity.trip_id)

      return true
    end
  end
  
  def going_on_same_trip(previous_activity, this_activity)
    if previous_activity.nil?
      return false
    elsif (previous_activity.action == this_activity.action and
          previous_activity.trip_id == this_activity.trip_id and 
          previous_activity.predicate == this_activity.predicate)

      return true
    end
  end
  
  def not_going_on_same_trip(next_activity, this_activity)
    if (next_activity.nil? or 
        next_activity.action != this_activity.action or 
        next_activity.trip_id != this_activity.trip_id or
        next_activity.predicate != this_activity.predicate)
        
      return true
    else
      return false
    end
  end
  
  def different_from_next_actvity(next_activity, this_activity)
    if (next_activity.nil? or 
        next_activity.user.id != this_activity.user.id or 
        next_activity.action != this_activity.action or 
        next_activity.trip_id != this_activity.trip_id)
        
      return true
    else
      return false
    end
  end
  
  def create_events_html(bunch_of_json_events, event_type, trip_href)
    idea_url = ""
    content = ""
    content +=  "<div id=\"events\" style=\"margin-left:-35px\">"
    
    bunch_of_json_events.each do |e|
      parsed_event = ActiveSupport::JSON.decode(e)
      parsed_trip = ActiveSupport::JSON.decode(trip_href) if !trip_href.nil? and !trip_href.include?("<a href=") # hack since some entries are in HTML
      next unless parsed_event
      
      idea = parsed_event[event_type]
      event = parsed_event["Event"]
      next if idea.nil? or event.nil?
      next if event["photo_file_size"].nil? and event["photo_file_name"].nil? and idea["lat"].nil? and idea["lng"].nil?
      
      # hack since some entries are in HTML
      idea_url = "<a class=\"ImgLink\" href=\"http://duffelup.com/trips/#{parsed_trip['permalink']}/ideas/#{event['id']}\">" if parsed_trip        
      
      content += "<div class=\"pin note\" style=\"height:265px;overflow:hidden;\">"
      
      if parsed_trip
        content += '<div class="actions">' +
          '<div class="add-to-duffel">' + build_url_for_copy("Add to my duffel", event['id'], parsed_trip['permalink']) + '</div>' +
          "<div class=\"like #{"disabled" if liked?(event['id'])}\" id=\"like_#{event['id']}\">"
          
          if liked?(event['id'])
            content += link_to_remote "Unlike", { :url => "/like/111/?event=#{event['id']}", :method => :delete }
          else
            content += link_to_remote "<span style=\"padding:0 0 2px 31px;background:url(/images/icon-favorite.png) no-repeat 10px -7px;z-index:3;\">Like this</span>", { :url => "/like/?event=#{event['id']}", :method => :post }, :style => "padding-left:0;"
          end
        content += "</div></div>"  
      end
      
      if event["photo_file_size"].nil? and event["photo_file_name"].nil? and !idea["lat"].nil? and !idea["lng"].nil?
        content += idea_url if parsed_trip #hack
        content += "<img class=\"map\" src=\"http://maps.google.com/maps/api/staticmap?center=#{idea["lat"].to_s[0..7]},#{idea["lng"].to_s[0..7]}&markers=size:small|#{idea["lat"].to_s[0..7]},#{idea["lng"].to_s[0..7]}&zoom=15&size=180x180&maptype=road&sensor=false\"/>"
        content += "</a>" if parsed_trip #hack
      elsif event["photo_file_size"].nil? and event["photo_file_name"]
        content += "<div style=\"overflow:hidden;text-align:center;\">"
        content += idea_url if parsed_trip #hack
        content += "<img style=\"height:180px\" src=\"#{event["photo_file_name"]}\"/>"
        content += "</a>" if parsed_trip
        content += "</div>"
      elsif event["photo_file_size"] and event["photo_file_name"]
        content += "<div style=\"overflow:hidden;text-align:center;\">"
        content += idea_url if parsed_trip #hack
        content += "<img style=\"height:180px\" src=\"http://s3.amazonaws.com/duffelup_event_#{RAILS_ENV}/photos/#{event["id"]}/thumb/#{event["photo_file_name"]}\"/>"
        content += "</a>" if parsed_trip
        content += "</div>"
      end
      
      content += "<h5 style=\"margin-top:5px\">" + truncate(unicode_to_utf8(event["title"]), :length => 55) + "</h5>"
      content += "<p class=\"description\">" + truncate(unicode_to_utf8(event["note"]), :length => 145) + "</p>"
      content +="</div>"
    end
    content += "</div>"
    
    return content
  end
  
  def create_url_from_trip_json(trip_string)
    return if trip_string.nil?
    
    if trip_string.include?("href")
      return trip_string
    else
      t = ActiveSupport::JSON.decode(trip_string)
      return "<a href=\"http://duffelup.com/trips/#{t['permalink']}\">#{t['title']}</a> to #{t['destination'].gsub('United States','')}"
    end
  end
end
