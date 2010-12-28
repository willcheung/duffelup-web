class Hotels < ActiveRecord::Base
  ########## IAN Hotels ############
  
  ENV['RAILS_ENV'] == 'production' ? BASE_URL = "http://duffelup.com/partner/?p=hotels&key=" : BASE_URL = "http://localhost:3000/partner/?p=hotels&key="
  ORIGINAL_URL = "http://reserve.duffelup.com/index.jsp?cid=261673"
  URL_PARAMS = "&pageName=hotInfo&cid=261673&hotelID="
  
  def self.insert_recommendation(destination, trip_id, start_date=nil, end_date=nil)
    # Parse locations
    split_dest = destination.split(";")
    
    split_dest.each do |d|
      
      # Find top hotels from hotels.com database
      # ian_hotels = self.find_ian_hotels_by_destination(d.strip, 2)
      # 
      # ian_hotels.each do |h|
      #   # Insert viator event into the duffel
      #   Idea.create_idea_in_duffel("Hotel", 
      #                             trip_id, 
      #                             h.name, 
      #                             h.description,
      #                             Hotels::ORIGINAL_URL + Hotels::URL_PARAMS + "#{h.id.to_s}", 
      #                             h.address1 + " " + h.city + " " + h.state + " " + h.country, 
      #                             "", 
      #                             {:file_name => h.thumb_url, :content => "", :size => ""}, 
      #                             h.low_rate,
      #                             Idea::PARTNER_ID["ian_hotel"],
      #                             h.latitude,
      #                             h.longitude)
      # end
      country = Country.find_by_sql(["select country_code from countries join cities on cities.country_id = countries.id where cities.city_country = ?", d])
      short_city_name = d.split(",")[0].gsub(" ", "-")
      
      if !country.nil? and !country.empty?
      
        country_code = country[0].country_code
  
        #Hotel Search
        #http://reserve.duffelup.com/index.jsp?cid=261673&pageName=hotSearch&submitted=true&validateDates=true&arrivalMonth=3&arrivalDay=3&departureMonth=3&departureDay=5&mode=2&numberOfRooms=1&numberOfAdults=2&numberOfChildren=0avail=true&passThrough=true&validateCity=true&city=Hoboken, NJ, United States
        if start_date.nil? or end_date.nil?
          #hotel_url = "http://reserve.duffelup.com/index.jsp?cid=261673&pageName=hotSearch&submitted=true&numberOfRooms=1&numberOfAdults=2&avail=true&passThrough=true&validateCity=true&city="+d
          #hotel_url = "http://www.booking.com/searchresults.html?aid=331036&ss="+short_city_name+"&si=ci&label=planning_page"
          hotel_url = "http://www.booking.com/city/"+country_code+"/"+short_city_name+".html?aid=331036"
        else
          #hotel_url = "http://reserve.duffelup.com/index.jsp?cid=261673&pageName=hotSearch&submitted=true&validateDates=true&arrivalMonth="+(start_date.month-1).to_s+"&arrivalDay="+start_date.day.to_s+"&departureMonth="+(end_date.month-1).to_s+"&departureDay="+end_date.day.to_s+"&numberOfRooms=1&numberOfAdults=2&avail=true&passThrough=true&validateCity=true&city="+d
          hotel_url = "http://www.booking.com/city/"+country_code+"/"+short_city_name+".html?aid=331036&checkin_monthday="+start_date.day.to_s+"&checkin_year_month="+start_date.year.to_s+"-"+start_date.month.to_s+"&checkout_monthday="+start_date.day.to_s+"&checkout_year_month="+end_date.year.to_s+"-"+end_date.month.to_s+"&do_availability_check=1"
          #hotel_url = "http://www.booking.com/searchresults.html?aid=331036&ss="+short_city_name+"&si=ci&checkin_year_month="+start_date.year.to_s+"-"+start_date.month.to_s+"&checkout_monthday="+end_date.day.to_s+"&checkout_year_month="+end_date.year.to_s+"-"+end_date.month.to_s+"&do_availability_check=1&label=planning_page"
        end
      
        # Insert link to hotels in the destination
        Idea.create_idea_in_duffel("Hotel", 
                                  trip_id, 
                                  "Top Rated Hotels in "+short_city_name, 
                                  "Suggested hotels in "+short_city_name+" from our partner.",
                                  hotel_url, 
                                  d, 
                                  "", 
                                  {:file_name => nil, :content => nil, :size => nil}, 
                                  0,
                                  0)
      end
    end
  end  
  
  def self.find_ian_hotels_by_destination(destination, limit, city_id=nil)
    if city_id.nil?
      w = "c.city_country"
      d = destination
    else
      w = "c.id"
      d = city_id.to_s
    end
    
    # Find hotel by city, country
    if destination.include?("United States")
      return self.find_by_sql(["select h.id, 
                                        h.name,
                                        h.address1,
                                        h.city,
                                        h.state,
                                        h.country,
                                        h.longitude,
                                        h.latitude,
                                        h.low_rate,
                                        h.high_rate,
                                        h.description,
                                        hi.thumb_url
                                  from hotels h 
                                  inner join hotel_images hi 
                                  on (hi.hotel_id = h.id and hi.caption = \"Exterior\")
                                  inner join cities c 
                                  on (c.city = h.city and c.region = h.state) 
                                  inner join countries cn 
                                  on (cn.country_code = h.country and c.country_id=cn.id)
                                  where " + w + "= ? and 
                                        h.confidence > 80
                                  group by h.id
                                  order by h.confidence DESC
                                  limit #{limit}", d])
    else
      return self.find_by_sql(["select h.id,
                                        h.name,
                                        h.address1,
                                        h.city,
                                        h.state,
                                        h.country,
                                        h.longitude,
                                        h.latitude,
                                        h.low_rate,
                                        h.high_rate,
                                        h.description,
                                        hi.thumb_url
                                  from hotels h 
                                  inner join hotel_images hi 
                                  on (hi.hotel_id = h.id and hi.caption = \"Exterior\")
                                  inner join cities c 
                                  on (c.city = h.city) 
                                  inner join countries cn 
                                  on (cn.country_code = h.country and c.country_id=cn.id)
                                  where " + w + " = ? and 
                                        h.confidence > 80
                                  group by h.id
                                  order by h.confidence DESC
                                  limit #{limit}", d])
    end
  end
end
