module ActivitiesFeedsHelper
  # only display feed when current_user is invited to the trip
  def display_private_duffel_feed(feed)
    if !@users_by_trip_id.nil? and !@users_by_trip_id[feed.trip_id.to_s].nil? 
      @users_by_trip_id[feed.trip_id.to_s].each do |u| 
        if u.id == current_user.id
          return true
        end
      end
    end
    
    return false
  end
end
