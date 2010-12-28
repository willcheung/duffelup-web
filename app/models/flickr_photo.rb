class FlickrPhoto < ActiveRecord::Base
  belongs_to :city
  
  def self.select_random_photo(city_id)
    self.find_by_sql(["Select * from flickr_photos where city_id=? order by RAND() limit 1", city_id])
  end
end
