class City < ActiveRecord::Base
  belongs_to :country
  has_one :featured_duffel
  has_many :activities
  has_many :foodanddrinks
  has_many :hotels
  #has_many :flickr_photos
  has_many :landmarks
  has_and_belongs_to_many :trips
  has_one :guide
  has_and_belongs_to_many :users #subscription (not users' home cities)
  
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  # Returns an array of ids if there are one or multiple cities and countries, separated by semi-colon (;).  
  # Otherwise, returns empty array.
  def self.find_id_by_city_country(city_country)
    city_ids = []
    
    return city_ids if city_country.nil?
    
    locations = self.parse_locations(city_country)
    
    locations.each do |location|
      tmp = nil
      if location.length == 2 or location.length == 3
        if location.length == 3 and (location[0].downcase == "united states" or location[0].downcase == "canada")
          tmp = self.find_by_sql("select cities.id, cities.airport_code, cities.city, cities.latitude, cities.longitude from cities inner join countries on cities.country_id = countries.id " +
                                  "where cities.city = \"" + location[2] + "\" and cities.region = \"" + location[1] + 
                                  "\" and countries.country_name = \"" + location[0] + "\" limit 1")
          unless tmp.empty? or tmp.nil?
            city_ids << tmp.first
          end
        else
          tmp = self.find_by_sql("select cities.id, cities.airport_code, cities.city, cities.latitude, cities.longitude from cities inner join countries on cities.country_id = countries.id " +
                                "where cities.city = \"" + location[1] + "\" and countries.country_name = \"" + location[0] + "\" limit 1")
          unless tmp.empty? or tmp.nil?
            city_ids << tmp.first
          end  
        end
      elsif location.length == 1
        tmp = self.find_by_sql("select cities.id, cities.city_country as city, cities.airport_code, cities.latitude, cities.longitude from cities where city_country = \"" + location[0] + "\" limit 1")
        unless tmp.empty? or tmp.nil?
          city_ids << tmp.first
        end
      end
    end
    
    return city_ids
  end
  
  def self.all
    self.find_by_sql("select c.id, 
                             c.city_country,
                             c.city,
                             c.region,
                             c.latitude,
                             c.longitude,
                             cn.country_code,
                             count(c.id) as trip_count
                      from   cities c
                      inner join countries cn on cn.id = c.country_id
                      inner join cities_trips ct on ct.city_id = c.id
                      group by c.id
                      order by trip_count DESC
                      limit 80")
  end
  
  def self.top_cities(country_id)
    self.find_by_sql(["select c.id, 
                             c.city_country,
                             c.city,
                             c.region,
                             c.latitude,
                             c.longitude,
                             cn.country_code,
                             count(c.id) as trip_count
                      from   cities c
                      inner join countries cn on cn.id = c.country_id
                      inner join cities_trips ct on ct.city_id = c.id
                      where c.country_id = ? and c.city != ''
                      group by c.id
                      order by trip_count DESC
                      limit 20", country_id])
  end
  
  # Counts public and private duffel.  Put the count in a hash and can be referenced by "0" or "1"
  def self.count_public_private_duffels(city_id)
    count = self.find_by_sql(["SELECT count(trips.id) as count, trips.is_public
                                  FROM trips 
                                  INNER JOIN `cities_trips` 
                                      ON trips.id = `cities_trips`.trip_id                                  
                                      and cities_trips.city_id = ? 
                                  GROUP BY trips.is_public", city_id])
                                  
    count_by_is_public = {} #create a hash so we can reference the values by is_public
    count.each do |c|
      count_by_is_public[c.is_public.to_s] = c.count.to_i
    end
    
    # manually insert 0 count when public or private duffels are not returned by query above
    count_by_is_public["0"] = 0 if count_by_is_public["0"].nil?
    count_by_is_public["1"] = 0 if count_by_is_public["1"].nil?
    
    return count_by_is_public
  end
  
  # Simple City Search
  def self.search(query, limit=6)
    self.find_by_sql(["SELECT cities.id, cities.city_country, cities.city, cities.region, countries.country_code
                        FROM cities 
                        INNER JOIN countries on cities.country_id = countries.id 
                        WHERE (LOWER(city_country) LIKE ?) 
                        ORDER BY rank, id LIMIT ?", "%"+query+"%", limit])
  end
  
  # Used by cities_controller to find city by city name and country code
  def self.find_by_city_name_and_country_code(city, country_code, region=nil)
    if region.nil?
      c = self.find_by_sql(["SELECT cities.id, cities.city_country, cities.city, countries.country_name
                              FROM cities 
                              INNER JOIN countries on cities.country_id = countries.id
                              WHERE cities.city=? AND countries.country_code=? limit 1", city, country_code])
    else
      c = self.find_by_sql(["SELECT cities.id, cities.city_country, cities.city, countries.country_name 
                              FROM cities 
                              INNER JOIN countries on cities.country_id = countries.id 
                              WHERE cities.city=? AND cities.region=? AND countries.country_code=? limit 1", city, region, country_code])
    end
    c.first
  end
  
  def self.find_by_country_code(country_code)
    c = self.find_by_sql(["Select cities.id, cities.city_country, cities.city, cities.country_id from cities inner join countries on cities.country_id=countries.id where countries.country_code=? and cities.city=?", country_code, ""])
    c.first
  end
  
  def self.find_city_country_code_by_city_country(city_country)
    c = self.find_by_sql(["Select cities.*, countries.country_code  from cities
                        inner join countries on cities.country_id = countries.id
                        where cities.city_country=?",city_country])
    c.first
  end
  
  private
  
  # Accepts a string such as "New York, NY, United States" and parses it into an array
  def self.parse_locations(string)
    locations = []
    
    locations_string = string.split(";")
    
    locations_string.each do |l|
      tmp = l.split(",")
      tmp.reverse! # Country is index 0
      tmp.each { |t| t.strip! }
      locations << tmp
    end
    
    return locations
    
  end
end
