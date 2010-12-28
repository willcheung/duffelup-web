class FeaturedDuffel < ActiveRecord::Base
  has_permalink :title
  
  belongs_to :user
  belongs_to :trip
  belongs_to :city
  
  validates_presence_of :user_id, :trip_id, :city_id, :city_country
  
  FEATURED_DUFFELS_PER_PAGE = 8
  
  def to_param
    permalink
  end
  
  def self.count_total_duffels
    self.count_by_sql("select count(distinct(trip_id)) as count
                          from featured_duffels")
  end
  
  def self.count_total_users
    self.count_by_sql("select count(distinct(user_id)) as count
                          from featured_duffels")
  end
  
  def self.count_total_cities
    self.count_by_sql("select count(distinct(city_id)) as count
                          from featured_duffels")
  end
  
  def self.cities
    self.find_by_sql("select c.city_country, c.city as city_name, c.region, cn.country_code, count(f.city_id) as count
                        from featured_duffels as f
                        join cities as c on f.city_id = c.id
                        join countries as cn on c.country_id = cn.id
                        group by f.city_id
                        order by count DESC
                        limit 50")
  end
  
  def self.find_per_page(page, per_page=25)
    paginate   :per_page => per_page, 
               :page => page, 
               :order => "created_at DESC",
               :include => [:user, :trip, :city]
  end
  
end
