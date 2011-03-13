class ActivitiesFeed < ActiveRecord::Base
  belongs_to :user
  
  ADD_COMMENT = 1
  ADD_FAVORITE = 2
  CREATE_TRIP = 3
  ADD_ACTIVITY = 4
  ADD_LODGING = 5
  ADD_FOODANDDRINK = 6
  ADD_TRANSPORTATION = 7
  ADD_NOTES = 8
  INVITE_TO_TRIP = 9
  APPROVE_FRIENDSHIP = 10
  DEPART_FOR_TRIP = 11
  RETURN_FROM_TRIP = 12
  ADD_ACTIVITY_CLIPIT = 13
  ADD_LODGING_CLIPIT = 14
  ADD_FOODANDDRINK_CLIPIT = 15
  ADD_TRANSPORTATION_CLIPIT = 16
  ADD_NOTES_CLIPIT = 17
  COPY_ACTIVITY = 18
  COPY_LODGING = 19
  COPY_FOODANDDRINK = 20
  COPY_TRANSPORTATION = 21
  COPY_NOTES = 22
  
  CLIP_IT_TEXT = " (via <a href=\"/site/tools/\">Clip-It</a>)."
  
  ###########################
  # Used for activities feed
  ###########################
  def content
    @content
  end
  
  def content=(body)
    @content=body
  end
  
  def self.insert_activity(actor, action, trip, predicate_text="")
    a = ActivitiesFeed.new
    
    name = (actor.full_name.nil? or actor.full_name.empty?) ? actor.username : actor.full_name
    
    a.user_id = actor.id
    a.actor = "<a href=\"/#{actor.username}\">#{name}</a>"
    a.action = action
    a.predicate = predicate_text
    
    if trip.nil?
      a.trip_id = nil
      a.trip = nil
      a.is_public = 1
    else
      a.trip_id = trip.id
      if action == ActivitiesFeed::ADD_COMMENT
        a.trip = "<a href=\"http://duffelup.com/trips/#{trip.permalink}#comments\">#{trip.title}</a> to #{truncate(trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" "),90)}"
      else
        a.trip = "<a href=\"http://duffelup.com/trips/#{trip.permalink}\">#{trip.title}</a> to #{truncate(trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" "),90)}"
      end
      a.is_public = trip.is_public
    end
    
    a.save
  end
  
  
  def self.get_activities(friends, page, per_page=20)
    f_ids = []
    
    friends.each do |f|
      f_ids << f.id
    end
    
    return if f_ids.empty?
    
    paginate   :per_page => per_page, :page => page, 
                      :select => "activities_feeds.*", 
                      :conditions => "activities_feeds.user_id in (#{f_ids.join(",")})",
                      :order => "activities_feeds.created_at DESC",
                      :include => :user

  end
  
  def self.get_all_activities(page, per_page=25) # Get all public activities

    paginate   :per_page => per_page, :page => page, 
                      :select => "activities_feeds.*", 
                      :order => "activities_feeds.created_at DESC",
                      :conditions => "activities_feeds.is_public = 1"

  end
  
  def self.group_activities(activities)
    grouped_activities = []
    names = "" # used for travelers going on the same trip
    counter = 1 # used to keep track of # of activities added
    
    return [] if activities.nil?

    activities.each_with_index do |a,i|
      previous_activity = (i == 0) ? nil : activities[i-1]
      next_activity = (i == (activities.size-1)) ? nil : activities[i+1]
      
      case a.action.to_i
      when ADD_COMMENT
        a.content = a.actor + " commented on " + a.trip + "." 
        grouped_activities << a
      when ADD_FAVORITE
        a.content = a.actor + " saved " + a.trip + " as their favorites."
        grouped_activities << a
      when CREATE_TRIP
        a.content = a.actor + " started planning " + a.trip + ". Any recommendations?"
        grouped_activities << a
      when ADD_ACTIVITY
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added an activity into " + a.trip + "." : a.actor + " added " + counter.to_s + " activities into " + a.trip + "."
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ADD_LODGING
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a lodging into " + a.trip + "." : a.actor + " added " + counter.to_s + " lodgings into " + a.trip + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end   
      when ADD_FOODANDDRINK
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a food & drink into " + a.trip + "." : a.actor + " added " + counter.to_s + " food & drinks into " + a.trip + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ADD_TRANSPORTATION
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a transportation into " + a.trip + "." : a.actor + " added " + counter.to_s + " transportations into " + a.trip + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ADD_NOTES
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a note into " + a.trip + "." : a.actor + " added " + counter.to_s + " notes into " + a.trip + "." 
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when ADD_ACTIVITY_CLIPIT
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added an activity into " + a.trip + CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " activities into " + a.trip + CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ADD_LODGING_CLIPIT
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a lodging into " + a.trip + CLIP_IT_TEXT : a.content = a.actor + " added " + counter.to_s + " lodgings into " + a.trip + CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ADD_FOODANDDRINK_CLIPIT
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a food & drink into " + a.trip + CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " food & drinks into " + a.trip + CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ADD_TRANSPORTATION_CLIPIT
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a transportation into " + a.trip + CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " transportations into " + a.trip + CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when ADD_NOTES_CLIPIT
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " added a note into " + a.trip + CLIP_IT_TEXT : a.actor + " added " + counter.to_s + " notes into " + a.trip + CLIP_IT_TEXT 
          counter = 1 #reset counter
          grouped_activities << a
        end
      when COPY_ACTIVITY
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied an activity from " + a.predicate + " into " + a.trip + "." : a.actor + " copied " + counter.to_s + " activities from " + a.predicate + " into " + a.trip + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when COPY_LODGING
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a lodging from " + a.predicate + " into " + a.trip + "." : a.actor + " copied " + counter.to_s + " lodgings from " + a.predicate + " into " + a.trip + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end   
      when COPY_FOODANDDRINK
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a food & drink from " + a.predicate + " into " + a.trip + "." : a.actor + " copied " + counter.to_s + " food & drinks from " + a.predicate + " into " + a.trip + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when COPY_TRANSPORTATION
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a transportation from " + a.predicate + " into " + a.trip + "." : a.actor + " copied " + counter.to_s + " transportations from " + a.predicate + " into " + a.trip + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when COPY_NOTES
        if same_as_previous_activity(previous_activity, a)
          counter = counter + 1
        end
        
        if different_from_next_actvity(next_activity, a)
          a.content = (counter == 1) ? a.actor + " copied a note from " + a.predicate + " into " + a.trip + "." : a.actor + " copied " + counter.to_s + " notes from " + a.predicate + " into " + a.trip + "."  
          counter = 1 #reset counter
          grouped_activities << a   
        end
      when INVITE_TO_TRIP
        a.content = a.actor + " invited " + a.predicate + " to " + a.trip + "."
        grouped_activities << a
      when APPROVE_FRIENDSHIP
        a.content = a.actor + " is now friends with " + a.predicate + "."
        grouped_activities << a
      when DEPART_FOR_TRIP
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
            a.content = a.actor + " is almost duffeled up for their trip " + a.trip + ". Any last minute travel tips?"
          else
            a.content = names + " and " + a.actor + " are almost duffeled up for their trip " + a.trip + ". Any last minute travel tips?"
            counter = 1
            grouped_activities << a
          end
        end
        
      when RETURN_FROM_TRIP
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
            a.content = a.actor + " just returned from their trip " + a.trip + ". They gotta post some pictures soon."
          else
            a.content = names + " and " + a.actor + " just returned from their trip " + a.trip + ". They gotta post some pictures soon."
            counter = 1
            grouped_activities << a
          end
        end
      end # end of case
    end # end of activities loop
    
    return grouped_activities
  end
  
  def self.same_as_previous_activity(previous_activity, this_activity)
    if previous_activity.nil?
      return false
    elsif (previous_activity.user.id == this_activity.user.id and 
          previous_activity.action == this_activity.action and
          previous_activity.trip_id == this_activity.trip_id and 
          previous_activity.predicate == this_activity.predicate)

      return true
    end
  end
  
  def self.going_on_same_trip(previous_activity, this_activity)
    if previous_activity.nil?
      return false
    elsif (previous_activity.action == this_activity.action and
          previous_activity.trip_id == this_activity.trip_id and 
          previous_activity.predicate == this_activity.predicate)

      return true
    end
  end
  
  def self.not_going_on_same_trip(next_activity, this_activity)
    if (next_activity.nil? or 
        next_activity.action != this_activity.action or 
        next_activity.trip_id != this_activity.trip_id or
        next_activity.predicate != this_activity.predicate)
        
      return true
    else
      return false
    end
  end
  
  def self.different_from_next_actvity(next_activity, this_activity)
    if (next_activity.nil? or 
        next_activity.user.id != this_activity.user.id or 
        next_activity.action != this_activity.action or 
        next_activity.trip_id != this_activity.trip_id or
        next_activity.predicate != this_activity.predicate)
        
      return true
    else
      return false
    end
  end
  
  # Source code from file vendor/rails/actionpack/lib/action_view/helpers/text_helper.rb, line 60
  def self.truncate(text, *args)
    options = args.extract_options!
    unless args.empty?
      # ActiveSupport::Deprecation.warn('truncate takes an option hash instead of separate ' +
      #         'length and omission arguments', caller)

      options[:length] = args[0] || 30
      options[:omission] = args[1] || "..."
    end
    options.reverse_merge!(:length => 30, :omission => "...")

    if text
      l = options[:length] - options[:omission].mb_chars.length
      chars = text.mb_chars
      (chars.length > options[:length] ? chars[0...l] + options[:omission] : text).to_s
    end
  end
  
  
end
