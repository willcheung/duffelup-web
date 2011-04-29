class Trip < ActiveRecord::Base
  has_permalink :title
  
  has_many :invitations, :dependent => :delete_all
  has_many :comments, :order => "created_at ASC", :include => 'user', :dependent => :delete_all
  has_many :events, :order => :position, :dependent => :destroy
  has_one :featured_duffel
  
  has_and_belongs_to_many :cities
  has_many :favorites, :include => 'user', :dependent => :delete_all
  
  has_many :admins,
           :through => :invitations,
           :source => :user,
           :conditions => "user_type = #{Invitation::USER_TYPE_ADMIN}"
  
  has_many :users,
           :through => :invitations,
           :order => :username
    

  # Photo using Paperclip plugin
  has_attached_file :photo,
        :styles => {
          :thumb => "125x125#",
          :small => "240x240#"},
        :storage => :s3,
        :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
        :path => ":attachment/:id/:style/:basename.:extension",
        :bucket => "duffelup_trip_#{RAILS_ENV}"
         
  # Photo
  validates_attachment_content_type :photo, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]
  validates_attachment_size :photo, :less_than => 3.megabyte
  
  validates_date :start_date, :end_date, :allow_nil => true
  validates_presence_of :title, :destination, :duration
  validates_as_positive_integer :duration 
  
  DATE_SELECT_SIZE = 18
  DURATION_FOR_NO_ITINERARY = 0
  PROFILE_DESTINATION_TRUNCATE_SIZE = 100
  PROFILE_TITLE_TRUNCATE_SIZE = 75
  DASHBOARD_DESTINATION_TRUNCATE_SIZE = 140
  DASHBOARD_TITLE_TRUNCATE_SIZE = 60
  NUM_OF_COMMENTS_TO_SHOW = 4
  
  attr_accessible :start_date, :end_date, :title, :destination, :photo, :is_public
  
  before_save :add_photo_size_to_user_bandwidth
  
  # Finds all the events and their details, sort them by position, group them by days, and returns the itinerary.
  def events_details
    itinerary = []
    tmp = []
    number_of_days = self.duration + 2 #6/1 to 6/2 is 2 days, and index starts at 0 so number_of_days is duration + 2
    
    events_with_details = self.eventables
    sorted = events_with_details.sort { |x,y| x[:position].to_i <=> y[:position].to_i }
    
    number_of_days.times do |day|
      sorted.each do |e|
        if e.list.to_i == day
          tmp << e
        end
      end
      itinerary << tmp
      tmp = []
    end
      
    ### Debug ###
    # number_of_days.times do |day|
    #       itinerary[day].each do |i|
    #         logger.error("******* Day "+day.to_s+ " has " + i.title)
    #       end
    #     end
    
    return itinerary
  end
  
  # Find airport code for Kayak
  def self.find_airport_codes_by_permalink(perma)
    tmp = Trip.find_by_sql(["SELECT t.*, c.airport_code 
                       FROM trips t 
                       INNER JOIN cities_trips ct on t.id = ct.trip_id 
                       INNER JOIN cities c on ct.city_id = c.id 
                       WHERE t.permalink = ?
                       LIMIT 1", perma])
                       
    t = tmp[0]
    
    if t.nil?
      return Trip.find_by_permalink(perma)
    else
      return t
    end
  end
  
  def self.find_city_id_by_permalink(perma)
    t = Trip.find_by_sql(["SELECT t.*, ct.city_id
                           FROM trips t 
                           LEFT JOIN cities_trips ct on t.id = ct.trip_id 
                           WHERE t.permalink = ?", perma])
                           
    return t[0]
  end
  
  def flickr_photos
    return Trip.find_by_sql(["SELECT * from flickr_photos WHERE flickr_photos.city_id = ?", self.city_id])
  end
  
  def self.find_favorites(user_id)
    Trip.find_by_sql(["SELECT trips.*, count(comments.id) as comment_count 
                                     FROM trips
                                     INNER JOIN favorites on trips.id = favorites.trip_id
                                     LEFT JOIN comments ON trips.id = comments.trip_id
                                     WHERE (favorites.user_id = ?)
                                     GROUP BY trips.id
                                     ORDER BY trips.start_date DESC", user_id])
  end
  
  def self.load_trips_and_comments_count(user_id)
    Trip.find_by_sql(["SELECT trips.*, count(comments.id) as comment_count
                                    FROM trips
                                    INNER JOIN invitations ON trips.id = invitations.trip_id 
                                    LEFT JOIN comments ON trips.id = comments.trip_id
                                    WHERE (invitations.user_id = ?)
                                    GROUP BY trips.id
                                    ORDER BY trips.created_at DESC", user_id])
  end
  
  def self.load_trips_for_widgets_and_comments_count(user_id)
    Trip.find_by_sql(["SELECT trips.*, invitations.user_type, count(comments.id) as comment_count 
                                    FROM trips
                                    INNER JOIN invitations ON trips.id = invitations.trip_id 
                                    LEFT JOIN comments ON trips.id = comments.trip_id
                                    WHERE (invitations.user_id = ?)
                                      and (trips.end_date >= FROM_DAYS(TO_DAYS(CURRENT_DATE)-7) or trips.start_date is NULL)
                                      and (trips.is_public = 1)
                                    GROUP BY trips.id
                                    ORDER BY trips.start_date DESC", user_id])
  end
  
  def self.find_trips_by_city(city_id, limit=9)
    Trip.find_by_sql(["SELECT trips.*, count(comments.id) as comment_count , count(favorites.id) as favorite_count
                                  FROM trips 
                                  INNER JOIN `cities_trips` 
                                    ON trips.id = `cities_trips`.trip_id 
                                  LEFT JOIN comments 
                                    ON trips.id = comments.trip_id
                                  LEFT JOIN favorites 
                                    ON trips.id = favorites.trip_id
                                  WHERE (`cities_trips`.city_id = ? ) 
                                    and (trips.start_date >= FROM_DAYS(TO_DAYS(CURRENT_DATE)-360) and trips.start_date <= FROM_DAYS(TO_DAYS(CURRENT_DATE)+30) or trips.start_date is NULL)
                                    and (trips.is_public = 1)
                                  GROUP BY trips.id
                                  ORDER BY trips.start_date DESC
                                  limit #{limit}", city_id])
                                  
  end
  
  def self.find_all_trips_by_city(city_id, page, per_page=6, order="trips.start_date DESC", condition="")
    paginate :per_page => per_page, :page => page, 
             :select => "trips.*, count(comments.id) as comment_count, count(favorites.id) as favorite_count",
             :conditions => ["(`cities_trips`.city_id = ? ) and (trips.is_public = 1)" + condition, city_id], 
             :joins => "INNER JOIN cities_trips ON trips.id = cities_trips.trip_id 
                        LEFT JOIN comments ON trips.id = comments.trip_id
                        LEFT JOIN favorites ON trips.id = favorites.trip_id",
             :order => order,
             :group => "trips.id"
  end
  
  def self.create_duffel_for_new_user(trip, current_user)
    t = Trip.new(trip)
    t.duration = 0
    t.active = 1
    
    if t.save
      # Invite self
      Invitation.invite_self(current_user, t)
      
      # Add to cities_trips
      t.cities << City.find_id_by_city_country(t.destination)
      
      # Create sample note
      Notes.create_introduction_note(t.id)
      
      # Create sample foodanddrink
      Idea.create_idea_in_duffel("Foodanddrink", 
                                t.id, 
                                "Clip restaurant options", 
                                "and delicious images from any website, using our Clip-It bookmarker.",
                                "http://duffelup.com/site/tools", 
                                "", 
                                "", 
                                {:file_name => "http://duffelup.com/images/trip/sample_fooddrink.jpg", :content => "image/jpeg", :size => nil}, 
                                0,
                                0)
      
      # Create sample activity
      Idea.create_idea_in_duffel("Activity", 
                                t.id, 
                                "Add an activity", 
                                "And invite friends to help you fill up your duffel with ideas. Enjoy!",
                                "", 
                                t.destination, 
                                "", 
                                {:file_name => nil, :content => nil, :size => nil}, 
                                0,
                                0)
      
      # Create sample transportation                        
      # Transportation.create_in_duffel("home", 
      #                                 nil, 
      #                                 nil, nil, t.id,
      #                                 "vacation",
      #                                 "Save your transportation details here.")
                                      
      # Create sample hotel
      # Idea.create_idea_in_duffel("Hotel", 
      #                           t.id, 
      #                           "Drag & drop me around the corkboard", 
      #                           "...and into the itinerary on the left!",
      #                           "", 
      #                           "", 
      #                           "", 
      #                           {:file_name => nil, :content => nil, :size => nil}, 
      #                           0,
      #                           0)
    end
  end
  
  def favorite?(user)
    Favorite.find_by_user_id_and_trip_id(user, self)
  end
  
  # Finds all events and their details
  def eventables
    self.mappable_ideas + self.notes + self.transportations
  end
  
  # Finds all ideas and check_ins ...
  # along with lat,lng and index them for numbered markers on the map.
  def mappable_ideas
    ideas = Event.find_ideas(self.id)
    ideas = ideas + self.check_ins
    
    count = 1
    ideas.each do |i|
      unless i[:lat].nil? and i[:lng].nil?
        if not i[:list] == 0 # if idea is on Itinerary
          i[:index] = count
          count += 1
        else # if idea is on Ideaboard
          i[:index] = 0
        end
      else
        i[:index] = nil
      end
    end
  end
  
  def notes
    Event.find_notes(self.id)
  end
  
  def transportations
    Event.find_transportations(self.id)
  end
  
  def check_ins
    Event.find_check_ins(self.id)
  end
  
  # Set trip as active.
  def activate
    self.update_attribute(:active, 1)
  end
    
  # This method intercepts the URL formation and adds trip name to the URL.
  def to_param
      permalink
  end
  
  def update_existing_cities(new_cities)
    tmp_new_cities = Array.new(new_cities) # to prevent tmp_new_cities to change with new_cities
    existing_cities = Array.new(self.cities) # to prevent existing_cities to change with trip.cities
    
    # find the diff b/t existing_cities and new_cities and update
    existing_cities.each { |existing_city| new_cities.reject! { |n| n.id == existing_city.id } }
    tmp_new_cities.each { |tmp_new_city| existing_cities.reject! { |n| n.id == tmp_new_city.id } }
    
    unless existing_cities.empty? or existing_cities.nil?
      existing_cities.each do |city|
        self.cities.delete(city)
      end 
    end
    
    unless new_cities.empty? or new_cities.nil?
      self.cities << new_cities
    end
  end
  
  def self.search(query, limit=5)
    self.find_by_sql(["SELECT trips.*, count(comments.id) as comment_count
                        FROM trips  
                        LEFT OUTER JOIN comments ON trips.id = comments.trip_id
                        WHERE ((trips.destination LIKE ?) or (trips.title LIKE ?)) 
                          and trips.is_public = 1
                          and (trips.start_date >= FROM_DAYS(TO_DAYS(CURRENT_DATE)-90) and trips.start_date <= FROM_DAYS(TO_DAYS(CURRENT_DATE)+30) or trips.start_date is NULL)
                        GROUP BY trips.id
                        LIMIT ?", "%"+query+"%", "%"+query+"%", limit])
  end
  
  def add_photo_size_to_user_bandwidth
    if self.photo_file_size_changed?
      user = User.find_by_id(self.admins[0].id)
      user.bandwidth = user.bandwidth + self.photo_file_size
      user.save(false)
    end
  end

end
