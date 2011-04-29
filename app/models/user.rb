require 'digest/sha1'
class User < ActiveRecord::Base
  # Beta Invitation
  has_many :sent_invitations, :class_name => 'BetaInvitation', :foreign_key => 'sender_id'
  belongs_to :beta_invitation
  has_one :featured_duffel
  
  has_and_belongs_to_many :cities, :include => :country #subscription (not home cities)
  
  has_many :comments, :order => "created_at DESC", :include => 'trip', :dependent => :delete_all
  has_many :api_keys
  
  # friendship rich association
  has_many :friendships, :dependent => :destroy
  has_many :favorites, :include => 'trip', :dependent => :destroy
  
  has_many :friends, 
           :through => :friendships,
           :conditions => "status = #{Friendship::ACCEPTED}", 
           :order => :username

  has_many :requested_friends, 
           :through => :friendships, 
           :source => :friend,
           :conditions => "status = #{Friendship::REQUESTED}", 
           :order => :username

  has_many :pending_friends, 
           :through => :friendships, 
           :source => :friend,
           :conditions => "status = #{Friendship::PENDING}", 
           :order => :username
  
  has_many :trips,
           :through => :invitations,
           :order => "trips.start_date DESC"

  has_many :trips_by_admin,
           :through => :invitations,
           :source => :trip,
           :conditions => "invitations.user_type = #{Invitation::USER_TYPE_ADMIN}",
           :dependent => :destroy
  
  # invitation rich association; didn't use HABTM because Invitation model has attributes
  has_many :invitations, :dependent => :destroy
  
  has_many :activities_feeds, :dependent => :destroy
  
  has_many :achievements, :dependent => :destroy, :include => :stamp
  has_many :stamps, :through => :achievements
           
  # Avatar using Paperclip plugin
  has_attached_file :avatar,
      :styles => {
        :thumb=> "80x80#",
        :medium  => "250x250#",
        :original  => "550x550>" }
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  # Max & min lengths for all fields 
  USERNAME_MIN_LENGTH = 3 
  USERNAME_MAX_LENGTH = 20 
  FULL_NAME_MAX_LENGTH = 40
  PASSWORD_MIN_LENGTH = 6 
  PASSWORD_MAX_LENGTH = 40 
  EMAIL_MAX_LENGTH = 50 
  USERNAME_RANGE = USERNAME_MIN_LENGTH..USERNAME_MAX_LENGTH 
  PASSWORD_RANGE = PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH 

  # Text box sizes for display in the views 
  USERNAME_SIZE = 30 
  PASSWORD_SIZE = 30 
  EMAIL_SIZE = 30
  FULL_NAME_SIZE = 30
  
  # User Types
  CATEGORY_DISABLED = 0
  CATEGORY_NORMAL = 1
  CATEGORY_PRO = 2
  CATEGORY_BUSINESS = 3
  
  # User Default Bandwidth
  UPLOAD_LIMIT = 30000000 # 30 MB
  
  # Email Settings
  EMAIL_NEWSLETTER = { "bit_position" => 0, "value" => 1 }
  EMAIL_DUFFEL_DESTINATIONS = { "bit_position" => 1, "value" => 2 }
  EMAIL_FAVORITE = { "bit_position" => 2, "value" => 4 }
  EMAIL_COMMENT = { "bit_position" => 3, "value" => 8 }
  EMAIL_TRIP_REMINDER = { "bit_position" => 4, "value" => 16 }
  
  # Avatar
  validates_attachment_content_type :avatar, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]
  validates_attachment_size :avatar, :less_than => 1.megabyte
  
  # User form validation
  validates_presence_of     :username, :email
  validates_presence_of     :password, :if => :password_required?
  validates_length_of       :password, :within => PASSWORD_RANGE, :if => :password_required?
  validates_length_of       :username, :within => USERNAME_RANGE
  validates_length_of       :email,    :maximum => EMAIL_MAX_LENGTH
  validates_uniqueness_of   :username, :email, :case_sensitive => false
  validates_format_of :username, 
                      :with => /^[A-Z0-9_]*$/i, 
                      :message => "must contain only letters, numbers, and underscores" 
  validates_format_of :email, 
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
                      :message => "must be a valid email address"
  before_save :encrypt_password
  
  # get city_id
  before_save :save_user_city_id
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :username, :email, :password, :full_name, :homepage, :bio, :home_city, :invitation_token, :avatar, :home_airport_code, :last_login_at, :avatar_file_name, :avatar_content_type, :email_updates, :hide_tour_at, :source, :twitter_secret, :twitter_token
  
  def self.find_users_by_trip_ids(trip_ids)
    return nil if trip_ids.nil? or trip_ids.empty?
    
    ids = trip_ids.join(",")
    users = User.find_by_sql("SELECT users.id, users.username, users.full_name, users.home_city, users.avatar_file_name, users.email_updates, invitations.trip_id, invitations.user_type
                                        FROM users
                                      INNER JOIN invitations 
                                        ON users.id = invitations.user_id 
                                      WHERE (invitations.trip_id in (#{ids}))")
                                      
    users.group_by(&:trip_id)
  end
  
  
  ################################################
  #               Facebook Connect              #
  ###############################################
  
  # Find the user in the database, first by the facebook user id and if that fails through the email hash
  def self.find_by_fb_user(fb_user)
    User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
  end
  
  # Take the data returned from facebook and create a new user from it.
  # We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  # If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def self.create_from_fb_connect(fb_user, source="facebook") 
    new_facebooker = User.new(:full_name => fb_user.name.to_s, 
                              :username => "#{fb_user.first_name.to_s}#{fb_user.last_name.to_s}"+rand(9).to_s, 
                              :password => "", 
                              :email => "",
                              :source => source,
                              :email_updates => 29,
                              :home_city => !fb_user.hometown_location.nil? ? (fb_user.hometown_location.city.to_s + " " + fb_user.hometown_location.state.to_s + ", " + fb_user.hometown_location.country.to_s) : "",
                              :avatar_file_name => fb_user.pic_square,
                              :avatar_content_type => "image/jpeg")
    new_facebooker.fb_user_id = fb_user.uid.to_i
    new_facebooker.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand}--")
    new_facebooker.save(false)
    # taking register to fb for now b/c of Unknown StandardError.
    # new_facebooker.register_user_to_fb 
    
    return new_facebooker
  end

  #We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id)
    unless fb_user_id.nil?
      #check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
      #link the new one
      self.fb_user_id = fb_user_id
      save(false)
    end
  end

  # The Facebook registers user method is going to send the users email hash and our account id to Facebook
  # We need this so Facebook can find friends on our local application even if they have not connect through connect
  # We then use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
  
  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end
  
  def twitter_user?
    return !twitter_token.nil? && !twitter_secret.nil?
  end
  
  ################################################
  #               Twitter OAuth                  #
  # http://twitter.rubyforge.org/
  ###############################################
  
  def self.create_from_twitter_oauth(twitter_user, token, secret)
    new_twitterer = User.new(:full_name => twitter_user.name.to_s, 
                              :username => "#{twitter_user.screen_name.to_s}"+rand(9999).to_s, 
                              :password => "", 
                              :email => "",
                              :email_updates => 29,
                              :source => "twitter",
                              :bio => twitter_user.description,
                              :home_city => twitter_user.location,
                              :avatar_file_name => twitter_user.profile_image_url,
                              :avatar_content_type => "image/jpeg",
                              :twitter_token => token,
                              :twitter_secret => secret)
    new_twitterer.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand}--")
    new_twitterer.save(false)
    
    return new_twitterer
  end
  
  
  ################################################
  #               Search Users                  #
  ###############################################
  
  def self.load_all_confirmed_friends(user_id)
    User.find_by_sql(["SELECT users.id, users.username, users.full_name, users.home_city, users.avatar_file_name, friendships.status 
                                     FROM users 
                                     INNER JOIN friendships ON users.id = friendships.friend_id 
                                     WHERE ((friendships.user_id = ?) AND (status = #{Friendship::ACCEPTED})) 
                                     ORDER BY friendships.updated_at", user_id])
  end
  
  def self.load_requested_friends(user_id)
    User.find_by_sql(["SELECT users.id, users.username, users.full_name, users.home_city, users.avatar_file_name, friendships.status 
                                     FROM users 
                                     INNER JOIN friendships ON users.id = friendships.friend_id 
                                     WHERE ((friendships.user_id = ?) AND (status = #{Friendship::REQUESTED})) 
                                     ORDER BY username", user_id])
  end
  
  def self.load_thirty_confirmed_friends(user_id)
    User.find_by_sql(["SELECT users.id, users.username, users.full_name, users.home_city, users.avatar_file_name, friendships.status 
                                     FROM users 
                                     INNER JOIN friendships ON users.id = friendships.friend_id 
                                     WHERE ((friendships.user_id = ?) AND (status = #{Friendship::ACCEPTED}))
                                     ORDER BY friendships.updated_at
                                     LIMIT 30", user_id])
  end
  
  def self.load_trip_users(trip_id)
    User.find_by_sql(["SELECT users.id, users.username, users.email, users.full_name, users.category, users.avatar_file_name, users.home_city, users.home_airport_code, users.email_updates,
                                      invitations.status as invite_status, invitations.user_type as user_type
                               FROM users INNER JOIN invitations ON users.id = invitations.user_id
                               WHERE ((invitations.trip_id = ?))", trip_id])
  end

  # Simple User Search
  def self.search(query, page, per_page=24)
    # :conditions => ["(username LIKE ? or full_name LIKE ?) and (friendships.friend_id=? or friendships.friend_id is NULL)", "%#{query}%", "%#{query}%", current_user_id], 

    paginate :per_page => per_page, :page => page, 
             :conditions => ["(username LIKE ? or full_name LIKE ? or email LIKE ?)", "%#{query}%", "%#{query}%", "%#{query}%"], 
             :order => 'username ASC', :include => 'friendships'
  end
  
  # Search only for user's friends
  def self.search_friends(user, page)
    paginate :per_page => 24, :page => page, 
             :conditions => ["(friendships.user_id=?) and (friendships.status=#{Friendship::ACCEPTED})", user], 
             :joins => "INNER JOIN friendships ON users.id = friendships.friend_id",
             :order => 'username ASC', :include => 'friendships'
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(username, password)
    # need to get the salt
    if username.include?("@")
      u = find_by_email(username)
    else
      u = find_by_username(username)
    end
    
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  # Beta Invitation
  def invitation_token
    beta_invitation.token if beta_invitation
  end

  def invitation_token=(token)
    self.beta_invitation = BetaInvitation.find_by_token(token)
  end
  
  
  protected
  
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    if facebook_user? or twitter_user?
      return false
    else
      crypted_password.blank? || !password.blank?
    end
  end
  
  def save_user_city_id
    _city_id = City.find_id_by_city_country(self.home_city)
    
    if _city_id.empty?
      self.city_id = 0
    else
      self.city_id = _city_id[0].id
      self.home_airport_code = _city_id[0].airport_code
    end
  end
    
end
