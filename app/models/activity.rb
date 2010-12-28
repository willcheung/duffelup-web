class Activity < Idea

  def create_activity(event, trip, current_user)
    # set attributes
    event.trip_id = trip.id
    
    return event
  end
end