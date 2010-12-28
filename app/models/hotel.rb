class Hotel < Idea

  def create_hotel(event, trip, current_user)
    # set attributes
    event.trip_id = trip.id
    
    return event
  end
end