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
  ADD_CHECK_IN = 23
  
  CLIP_IT_TEXT = " (via <a href=\"/site/tools/\">Bookmarklet</a>)."
  
  ###########################
  # Used for activities feed
  ###########################
  def content
    @content
  end
  
  def content=(body)
    @content=body
  end
  
  def self.insert_activity(actor, action, trip, predicate_text="", event=nil, check_in_is_public=nil)
    a = ActivitiesFeed.new
    
    name = (actor.full_name.nil? or actor.full_name.empty?) ? actor.username : actor.full_name
    
    a.user_id = actor.id
    a.actor = "<a href=\"/#{actor.username}\">#{name}</a>"
    a.action = action
    a.predicate = predicate_text
    a.title = event.title unless event.nil?
    
    if trip.nil?
      a.trip_id = nil
      a.trip = nil
      a.is_public = 1
    else
      a.trip_id = trip.id
      a.trip = trip.to_json
      
      if action == ActivitiesFeed::ADD_CHECK_IN 
        # check_in is_public flag overwrites trip is_public flag for news feed
        a.is_public = check_in_is_public
        a.photo_url = event.photo.url(:thumb)
      else
        a.is_public = trip.is_public
      end
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
  
end
