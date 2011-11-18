class Event < ActiveRecord::Base
  # To Do: Multiple table inheiritance http://mediumexposure.com/multiple-table-inheritance-active-record/
  belongs_to :eventable, :polymorphic => true, :dependent => :delete
  belongs_to :trip
  belongs_to :user, :foreign_key => :created_by
  
  # Polymorphic Through relationship: http://blog.hasmanythrough.com/2006/4/3/polymorphic-through
  # Not being used right now
  belongs_to :foodanddrink, :class_name => "Foodanddrink", :foreign_key => "eventable_id"
  belongs_to :activity, :class_name => "Activity", :foreign_key => "eventable_id"
  belongs_to :hotel, :class_name => "Hotel", :foreign_key => "eventable_id"
  belongs_to :transportation, :class_name => "Transportation", :foreign_key => "eventable_id"
  belongs_to :notes, :class_name => "Notes", :foreign_key => "eventable_id"
  
  has_many :likes
  
  acts_as_list :scope => :trip_id, :order => :position
  
  validates_presence_of :trip_id
  
  TRUNCATE_SHORT_NOTE_ON_BOARD_BY = 145
  TRUNCATE_VIATOR_SHORT_NOTE_ON_BOARD_BY = 165
  TRUNCATE_HOTELS_SHORT_NOTE_ON_BOARD_BY = 180
  TRUNCATE_NOTE_ON_BOARD_BY = 230
  TRUNCATE_TITLE_LENGTH_ON_TILE = 45
  TRUNCATE_TITLE_LENGTH_ON_ITINERARY = 30
  TRUNCATE_NOTE_ON_CITY_PAGE = 400
  
  # For drop-down menu in research/new
  EVENT_TYPE = [
    ["Activity", "Activity"],
    ["Food & Drink", "Foodanddrink"],
    ["Lodging", "Hotel"],
    ["Transportation", "Transportation"],
    ["Note", "Notes"]
    ]
    
  # For drop-down menu in events/edit  
  IDEA_EVENT_TYPE = [
    ["Activity", "Activity"],
    ["Food & Drink", "Foodanddrink"],
    ["Lodging", "Hotel"]
    ]
    
  has_attached_file :photo,
                    :styles => {
                      :thumb => "190x190#",
                      :medium => "350x350#",
                      :large  => "600x600#" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
                    :path => ":attachment/:id/:style/:basename.:extension",
                    :bucket => "duffelup_event_#{RAILS_ENV}"
                    
  validates_attachment_content_type :photo, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]
  
  attr_accessible :title, :note, :photo, :trip_id, :eventable_type
  
  #before_save :add_photo_size_to_user_bandwidth
  
  def self.find_ideas(trip_id, event_id=nil)
    sql = "SELECT ideas.*, events.*, users.username as author
                      FROM `ideas` 
                      INNER JOIN events ON ideas.id = events.eventable_id 
                      LEFT JOIN users ON events.created_by = users.id
                      WHERE ((`events`.trip_id = #{trip_id})"
    
    if !event_id.nil?
      sql = sql + " AND (events.id = #{event_id})"
    end
    
    sql = sql + " AND ((events.eventable_type = 'Activity') 
                  or (events.eventable_type = 'Hotel') 
                  or (events.eventable_type = 'Foodanddrink')))
              ORDER BY events.list, events.position"
    
    ideas = self.find_by_sql(sql)
  end
  
  def self.find_ideas_by_city(city_id, page, per_page=18)
    paginate  :per_page => per_page, :page => page, 
                      :select => "ideas.*, events.*, users.username as author, trips.is_public as public_trip, trips.permalink as trip_perma, trips.title as trip_title", 
                      :conditions => "((ideas.city_id = #{city_id})
                                          AND trips.is_public = 1
                                          AND ((events.eventable_type = 'Activity') 
                                          OR (events.eventable_type = 'Hotel') 
                                          OR (events.eventable_type = 'Foodanddrink')))",
                      :from => :ideas,
                      :joins => "INNER JOIN events ON ideas.id = events.eventable_id 
                                 INNER JOIN trips ON events.trip_id = trips.id
                                 INNER JOIN users ON events.created_by = users.id",
                      :order => "events.created_at desc"
    
    # sql = "SELECT ideas.*, events.*, users.username as author, trips.is_public as public_trip, trips.permalink as trip_perma, trips.title as trip_title
    #                       FROM `ideas` 
    #                   INNER JOIN events ON ideas.id = events.eventable_id 
    #                   INNER JOIN trips ON events.trip_id = trips.id
    #                   INNER JOIN users ON events.created_by = users.id
    #                       WHERE ((ideas.city_id = #{city_id})
    #                       AND ((events.eventable_type = 'Activity') 
    #                       OR (events.eventable_type = 'Hotel') 
    #                       OR (events.eventable_type = 'Foodanddrink')))
    #                   ORDER BY events.created_at desc limit 12"
    # 
    # ideas = self.find_by_sql(sql)
  end
  
  def self.find_transportations(trip_id, event_id=nil)
    sql = "SELECT transportations.*, events.*, users.username as author
                      FROM `transportations` 
                      INNER JOIN events ON transportations.id = events.eventable_id 
                      LEFT JOIN users ON events.created_by = users.id
                      WHERE ((`events`.trip_id = #{trip_id})"
                      
    if !event_id.nil?
      sql = sql + " AND (events.id = #{event_id})"
    end
                      
    sql = sql + " AND (events.eventable_type = 'Transportation'))
              ORDER BY events.list, events.position"
    
    transportations = self.find_by_sql(sql)
  end
  
  def self.find_notes(trip_id, event_id=nil)
    sql = "SELECT notes.*, events.*, users.username as author
                      FROM `notes` 
                      INNER JOIN events ON notes.id = events.eventable_id 
                      LEFT JOIN users ON events.created_by = users.id
                      WHERE ((`events`.trip_id = #{trip_id})"
    
    if !event_id.nil?
      sql = sql + " AND (events.id = #{event_id})"
    end                  
                             
    sql = sql + " AND (events.eventable_type = 'Notes'))
            ORDER BY events.list, events.position"
    
    notes = self.find_by_sql(sql)
  end
  
  def self.find_check_ins(trip_id, event_id=nil)
    sql = "SELECT check_ins.*, events.*, users.username as author
                      FROM `check_ins` 
                      INNER JOIN events ON check_ins.id = events.eventable_id 
                      LEFT JOIN users ON events.created_by = users.id
                      WHERE ((`events`.trip_id = #{trip_id})"
    
    if !event_id.nil?
      sql = sql + " AND (events.id = #{event_id})"
    end
                                       
    sql = sql + " AND (events.eventable_type = 'CheckIn'))
          ORDER BY events.list, events.position"
    
    notes = self.find_by_sql(sql)
  end
  
  def self.update_itinerary(trip_id, parameters, list)
    in_list = []
    sortables = parameters
    statement = "UPDATE events SET "
    p_statement = "position = CASE id "
    l_statement = "list = CASE id "
    
    sortables.each do |id|
      position = sortables.index(id) + 1
      # Then update the list with valid elements. (deprecated this b/c of performance issues)
      #ActiveRecord::Base.connection.execute("UPDATE events SET position=" + position.to_s + ", list=" + list + " where id=" + id)
       
      p_statement = p_statement + " WHEN " + id +
      " THEN " + position.to_s
      
      l_statement = l_statement + " WHEN " + id + 
      " THEN " + list
      
      in_list << "'" + id + "'"
    end
    
    statement = statement + p_statement + " END, " + l_statement + " END " + "WHERE trip_id = " + trip_id.to_s + " AND id IN (" + in_list.join(',') + ")"
    
    ActiveRecord::Base.connection.execute(statement)
  end
  
  def add_photo_size_to_user_bandwidth
    if self.photo_file_size_changed? and !user.nil?
      user.update_attribute("bandwidth", (user.bandwidth + self.photo_file_size))
      #user = User.find_by_id(self.created_by)
      #user.bandwidth = user.bandwidth + self.photo_file_size
      #user.save(false)
    end
  end
  
end
