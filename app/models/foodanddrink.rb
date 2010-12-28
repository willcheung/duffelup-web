class Foodanddrink < Idea
  
  def create_foodanddrink(event, trip, current_user)
    # set attributes
    event.trip_id = trip.id
    
    return event
  end
end