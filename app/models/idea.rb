class Idea < ActiveRecord::Base
  has_one :event, :as => :eventable
  has_many :trips, :through => :events
  belongs_to :city
  
  attr_accessible :phone, :address, :website, :price_range
  
  acts_as_mappable :auto_geocode => {:field => :address, :error_message=>'could not be found'}
  
  # For partners
  PARTNER_ID = {
    "viator" => "1",
    "ian_hotel" => "2"
  }
  
  # monkey patch STI / Polymorphic conflict.  What this does is setting "eventable_type" to type of 
  # Idea's children, but the "type" in Idea will be null.
  self.abstract_class = true 
  
  def self.create_idea_in_duffel(type, trip_id, title, note, website, address, phone, photo, price, partner_id, lat=nil, lng=nil)
    if type == "Foodanddrink"
      idea = Foodanddrink.new
    elsif type == "Hotel"
      idea = Hotel.new
    else #type == "Activity" or anything else
      idea = Activity.new
    end
    
    event = idea.create_event
    
    event.trip_id = trip_id
    event.title = title
    event.note = note.gsub(/<\/?[^>]*>/, "") # remove HTML tags
    event.price = price
    event.photo_file_name = photo[:file_name]
    idea.lat = lat unless lat.nil?
    idea.lng = lng unless lng.nil?
    idea.website = website
    idea.address = address
    idea.phone = phone
    idea.partner_id = partner_id
    idea.save!
  end
  
  def find_by_city_id(city_id, type)
    #select count(*) from ideas join events on ideas.id = events.eventable_id join trips on events.trip_id = trips.id where trips.is_public=1 and ideas.city_id=610 and (ideas.type="Activity" or ideas.type is null) and events.eventable_type="Activity" and ideas.partner_id=0
  end
  
end
