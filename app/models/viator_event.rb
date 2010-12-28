class ViatorEvent < ActiveRecord::Base
  belongs_to :viator_destination
  
  ORIGINAL_URL = "http://www.partner.viator.com/en/7101"
  
  def self.insert_recommendation(destination, trip_id, viator_idea_ids=nil)
    # Parse locations
    split_dest = destination.split(";")
    
    split_dest.each do |d|
      d.strip!
      
      # Check if variable "d" is empty string
      next if d.empty?
      
      # Find viator event by city, country or ids
      if viator_idea_ids.nil?
        viator_ideas = self.find_viator_events_by_destination(d, 2)
      else
        viator_ideas = self.find(viator_idea_ids)
      end
      
      viator_ideas.each do |v|
        # Insert viator event into the duffel
        Idea.create_idea_in_duffel("Activity", 
                                  trip_id, 
                                  v.product_name, 
                                  v.introduction,
                                  v.product_url, 
                                  d, 
                                  "", 
                                  {:file_name => v.product_image_thumb, :content => "image/jpeg", :size => ""}, 
                                  v.price, 
                                  Idea::PARTNER_ID["viator"])
      end
      
      # if ids are nil, that means the form is submitted during trip creation
      if viator_idea_ids.nil?
        # Find viator destination URL
        viator_destinations = self.find_viator_destination(d)
      
        viator_destinations.each do |vd|
          Idea.create_idea_in_duffel("Activity", 
                                    trip_id, 
                                    "Popular Activities & Tours in " + vd.destination_name, 
                                    "Click on \"+Activity\" at top left of this corkboard to add more activities directly to your duffel!",
                                    vd.destination_url.strip, 
                                    d, 
                                    "", 
                                    {:file_name => nil, :content => nil, :size => nil}, 
                                    0, 
                                    0)
        end
      end
    end
  end
  
  def self.find_viator_events_by_destination(destination, limit, city_id=nil)
    if city_id.nil?
      w = "c.city_country"
      d = destination
    else
      w = "c.id"
      d = city_id.to_s
    end
    
    self.find_by_sql(["select v.id,
                              v.product_name,
                              v.introduction,
                              v.product_image,
                              v.product_image_thumb,
                              v.product_url,
                              v.price,
                              v.duration,
                              v.city
                            from viator_events v 
                            inner join cities c on c.airport_code = v.iata_code 
                            where " + w + "=? and 
                              v.price < 201 and 
                              v.price > 2 and
                              v.avg_rating > 3
                            order by v.id
                            limit #{limit.to_s}", d])
  end
  
  def self.find_viator_destination(destination)    
    self.find_by_sql(["Select id,destination_name,destination_url from viator_destinations where destination_name like ?", "%"+destination+"%"])
  end
  
  def self.search(destination)
    w = "cities.city_country"
    d = destination
    
    self.find(:all,  
             :joins => "inner join cities on cities.airport_code = viator_events.iata_code",
             :conditions => ["(#{w}=?)", "#{d}"], 
             :order => 'viator_events.id')
  end
  
  def self.count_by_city(destination)
    w = "cities.city_country"
    d = destination
    
    self.count(:joins => "inner join cities on cities.airport_code = viator_events.iata_code", :conditions => ["(#{w}=?)", "#{d}"])
  end
end
