class Transportation < ActiveRecord::Base
  has_one :event, :as => :eventable

  validates_date_time :arrival_time, :departure_time, :allow_nil => true
  
  DATETIME_SELECT_SIZE = 24
  
  attr_accessible :to, :from, :arrival_time, :departure_time
  
  def create_transportation(event, trip)
    # set attributes
    event.title = self.from + " &rarr; " + self.to
    event.trip_id = trip.id
  end
  
  def self.create_in_duffel(home_airport, destination, start_date, end_date, trip_id, trip_destination, note)
    if destination.nil?
      dest_airport = trip_destination
    elsif destination.airport_code.nil? or destination.airport_code.empty?
      dest_airport = destination.city
    else
      dest_airport = destination.airport_code
    end
    
    home_airport.to_s.upcase! #upcase users' airport codes
    
    ############# Departure transportation ############
    t = Transportation.new(:departure_time => (start_date.strftime("%m/%d/%Y") + " 8:00 AM" unless start_date.nil?),
                                     :from => home_airport.to_s,
                                     :arrival_time => (start_date.strftime("%m/%d/%Y") + " 9:00 AM" unless start_date.nil?),
                                     :to => dest_airport.to_s)
                                        
    e = t.create_event

    e.trip_id = trip_id
    e.title = home_airport.to_s + " &rarr; " + dest_airport.to_s
    e.note = note
    t.save!
  end
  
end
