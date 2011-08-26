class Notes < ActiveRecord::Base
  has_one :event, :as => :eventable
  
  attr_accessible :content
  
  def self.create_to_bring_note(trip_id)
    notes = Notes.new
    event = notes.create_event
    
    notes.content = "camera charger\nphone charger\npassport\nother important stuff"
    
    event.trip_id = trip_id
    event.title = "Remember to bring"
    event.note = ""
    notes.save!
  end
  
  def self.create_introduction_note(trip_id)
    notes = Notes.new
    event = notes.create_event
    
    notes.content = "This corkboard helps organize your travel ideas. \n\nCreate notes, to-dos, and reminders. Drag me into the itinerary on the left."
    
    event.trip_id = trip_id
    event.title = "Welcome to Duffel!"
    event.note = ""
    notes.save!
  end
  
  def create_notes(event, trip)
    # set attributes
    event.trip_id = trip.id
    
    return event
  end
  
end
