class SplendiaHotel < ActiveRecord::Base

  API_URL = "http://api.splendia.com/?Partnerid=A434"
  
  def self.columns
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :hotel_id, :integer
  column :name, :string
  column :min_price, :float
  column :currency, :string
  column :country_code, :string
  column :client_rating_value, :integer
  column :client_rating_num, :integer
  column :description, :text
  column :image_url, :string
  column :big_image_url, :string
  column :latitude, :precision => 11, :scale => 6
  column :longitude, :precision => 11, :scale => 6
  column :address, :string
  column :city_country, :string
  column :postal_code, :string
  
  def self.get_hotel_by_lat_lng(lat,lng,radius=80)
    # radius = km
    
    hotel_collection = []
    
    url = API_URL + "&Service=getHotelCatalog&Destinationid=0&Latitude="+lat.to_s+"&Longitude="+lng.to_s+"&Radius="+radius.to_s+"&Currency=USD&Order=rating"
    
    hotels_doc = WebApp.consume_xml_from_url(url)
    
    (hotels_doc/:node).each do |hotel|
      
      tmp = (hotel/:node/:idhotel).first
      
      if tmp.nil?
        next
      end
    
      hotel_obj = SplendiaHotel.new(
        :hotel_id => tmp.innerHTML,
        :name => (hotel/:name).innerHTML,
        :min_price => (hotel/:min_price).first.innerHTML,
        :currency => (hotel/:currency).innerHTML,
        :country_code => (hotel/:country_code).innerHTML,
        :client_rating_value => (hotel/:client_rating_value).innerHTML,
        :client_rating_num => (hotel/:client_rating_num).innerHTML,
        :description => (hotel/:description).innerHTML,
        :image_url => (hotel/:image_path).innerHTML,
        :big_image_url => (hotel/:big_image_path).innerHTML,
        :latitude => (hotel/:latitude).innerHTML,
        :longitude => (hotel/:longitude).innerHTML,
        :address => (hotel/:street_name).innerHTML,
        :city_country => (hotel/:city_name).innerHTML + " " + (hotel/:country_name).innerHTML,
        :postal_code => (hotel/:postal_cde).innerHTML
      )
      hotel_collection << hotel_obj
    end
    
    return hotel_collection
    
  end
  
  def self.insert_recommendation(city, trip_id, start_date=nil, end_date=nil)
    splendia_hotels = SplendiaHotel.get_hotel_by_lat_lng(city.latitude, city.longitude)
    
    splendia_hotels.each_with_index do |h,i|
      break if i==2 # only insert 2 hotels
      
      hotel_url = "http://duffelup.com/hotels?hotel_id="+ h.hotel_id.to_s
      if !start_date.nil? and !end_date.nil?
        hotel_url = hotel_url + "&datestart=" + start_date.strftime("%d/%m/%y") + "&dateend=" + end_date.strftime("%d/%m/%y")
      end
      
      # Insert splendia hotel into the duffel
      Idea.create_idea_in_duffel("Hotel", 
                                trip_id, 
                                h.name, 
                                h.description,
                                hotel_url, 
                                h.address + " " + h.city_country + " " + h.postal_code, 
                                "", 
                                {:file_name => h.image_url, :content => "image/jpeg", :size => ""}, 
                                h.min_price, 
                                Idea::PARTNER_ID["splendia"],
                                h.latitude,
                                h.longitude)
    end
  end

end
