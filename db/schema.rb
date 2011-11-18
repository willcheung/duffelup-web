# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 30000000000038) do

  create_table "achievements", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "stamp_id"
  end

  create_table "activities_feeds", :force => true do |t|
    t.integer  "user_id",                                 :null => false
    t.string   "trip"
    t.datetime "created_at"
    t.string   "actor"
    t.integer  "trip_id"
    t.integer  "action",     :limit => 2
    t.integer  "is_public",  :limit => 1
    t.string   "predicate"
    t.string   "photo_url",               :default => "", :null => false
    t.string   "title",                   :default => "", :null => false
  end

  create_table "announcements", :force => true do |t|
    t.text     "message"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "api_keys", :force => true do |t|
    t.integer  "user_id"
    t.string   "key",        :limit => 30
    t.string   "source",     :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beta_invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.integer  "trip_id"
  end

  create_table "check_ins", :force => true do |t|
    t.integer  "city_id",                                                      :null => false
    t.decimal  "lat",        :precision => 15, :scale => 10
    t.decimal  "lng",        :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",                                  :default => true
  end

  create_table "cities", :force => true do |t|
    t.integer "country_id",                :null => false
    t.string  "region"
    t.string  "city"
    t.float   "latitude"
    t.float   "longitude"
    t.string  "city_country"
    t.string  "airport_code", :limit => 3
    t.integer "rank",         :limit => 1
  end

  add_index "cities", ["airport_code"], :name => "cities_airport_code"
  add_index "cities", ["city"], :name => "index_cities_on_city"
  add_index "cities", ["city_country"], :name => "city_country_optimization"
  add_index "cities", ["region"], :name => "index_cities_on_region"

  create_table "cities_staging", :force => true do |t|
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.float  "latitude"
    t.float  "longitude"
    t.string "city_country"
  end

  create_table "cities_trips", :id => false, :force => true do |t|
    t.integer "city_id", :null => false
    t.integer "trip_id", :null => false
  end

  create_table "cities_users", :id => false, :force => true do |t|
    t.integer "city_id", :null => false
    t.integer "user_id", :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "trip_id",    :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string "country_code", :limit => 2
    t.string "country_name"
  end

  create_table "events", :force => true do |t|
    t.integer  "trip_id",                             :null => false
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.integer  "position",                            :null => false
    t.integer  "list",               :default => 0,   :null => false
    t.string   "title",                               :null => false
    t.text     "note",                                :null => false
    t.integer  "created_by"
    t.integer  "bookmarklet"
    t.float    "price",              :default => 0.0, :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "trip_id",      :null => false
    t.datetime "favorited_at"
  end

  create_table "featured_duffels", :force => true do |t|
    t.string   "title",        :null => false
    t.string   "permalink",    :null => false
    t.integer  "city_id",      :null => false
    t.string   "city_country", :null => false
    t.integer  "user_id",      :null => false
    t.integer  "trip_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flickr_photos", :force => true do |t|
    t.integer "city_id"
    t.string  "title"
    t.string  "owner_name"
    t.string  "photo_url"
    t.string  "url_square"
    t.string  "url_small"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "friend_id",   :null => false
    t.integer  "status",      :null => false
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guides", :force => true do |t|
    t.integer  "city_id",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "is_published", :default => false
    t.text     "fun_facts"
  end

  create_table "hotel_images", :force => true do |t|
    t.integer "hotel_id"
    t.string  "name"
    t.string  "caption"
    t.string  "url"
    t.string  "thumb_url"
  end

  add_index "hotel_images", ["hotel_id"], :name => "index_hotel_images_on_hotel_id"

  create_table "hotels", :force => true do |t|
    t.string  "name"
    t.string  "airport_code",    :limit => 3
    t.string  "address1"
    t.string  "address2"
    t.string  "address3"
    t.string  "city"
    t.string  "state"
    t.string  "country"
    t.decimal "longitude",                    :precision => 11, :scale => 6
    t.decimal "latitude",                     :precision => 11, :scale => 6
    t.float   "low_rate"
    t.float   "high_rate"
    t.integer "marketing_level"
    t.integer "confidence"
    t.text    "description"
    t.string  "url"
    t.string  "image_url"
    t.string  "currency",        :limit => 3
    t.integer "rank",            :limit => 1
  end

  add_index "hotels", ["airport_code"], :name => "hotels_airport_code"
  add_index "hotels", ["city"], :name => "index_hotels_on_city"
  add_index "hotels", ["country"], :name => "index_hotels_on_country"
  add_index "hotels", ["state"], :name => "index_hotels_on_state"

  create_table "ideas", :force => true do |t|
    t.integer  "city_id",                                                                 :null => false
    t.string   "type"
    t.string   "phone"
    t.string   "address"
    t.string   "website"
    t.decimal  "lat",                      :precision => 15, :scale => 10
    t.decimal  "lng",                      :precision => 15, :scale => 10
    t.integer  "partner_id",                                               :default => 0, :null => false
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "price_range", :limit => 1
  end

  create_table "invitations", :force => true do |t|
    t.integer "user_id",                     :null => false
    t.integer "trip_id",                     :null => false
    t.integer "user_type",                   :null => false
    t.integer "status",                      :null => false
    t.integer "email_update", :default => 0, :null => false
  end

  create_table "landmarks", :force => true do |t|
    t.integer  "guide_id"
    t.string   "name",        :limit => 50
    t.text     "description"
    t.decimal  "lat",                       :precision => 15, :scale => 10
    t.decimal  "lng",                       :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "fun_facts"
    t.text     "tips"
    t.string   "address"
    t.integer  "city_id"
  end

  create_table "likes", :force => true do |t|
    t.datetime "acted_on"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["event_id"], :name => "index_likes_on_event_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "notes", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stamps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "landmark_id"
    t.string   "image_url"
  end

  add_index "stamps", ["landmark_id"], :name => "index_stamps_on_landmark_id"

  create_table "transportations", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "trips", :force => true do |t|
    t.string   "title",                             :null => false
    t.string   "permalink",                         :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "duration",                          :null => false
    t.integer  "is_public",          :default => 1, :null => false
    t.string   "destination",                       :null => false
    t.integer  "active",             :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
  end

  create_table "users", :force => true do |t|
    t.string   "username",                                               :null => false
    t.string   "email",                                                  :null => false
    t.string   "full_name"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "home_city"
    t.integer  "city_id",                                 :default => 0, :null => false
    t.string   "bio"
    t.string   "homepage"
    t.integer  "category",                                :default => 1, :null => false
    t.integer  "beta_invitation_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "last_login_at"
    t.string   "home_airport_code",         :limit => 3
    t.integer  "fb_user_id",                :limit => 8
    t.string   "email_hash"
    t.integer  "email_updates",             :limit => 1,  :default => 1
    t.datetime "hide_tour_at"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.integer  "bandwidth",                               :default => 0
    t.string   "source",                    :limit => 20
  end

  create_table "viator_destinations", :force => true do |t|
    t.string   "destination_name"
    t.string   "destination_type"
    t.integer  "parent_id"
    t.string   "parent_name"
    t.string   "iata_code"
    t.string   "destination_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "viator_events", :force => true do |t|
    t.string  "product_code"
    t.string  "product_name"
    t.text    "introduction"
    t.string  "duration"
    t.string  "product_image"
    t.string  "product_image_thumb"
    t.integer "viator_destination_id"
    t.string  "country"
    t.string  "region"
    t.string  "city"
    t.string  "iata_code"
    t.string  "product_url"
    t.float   "price"
    t.float   "avg_rating"
  end

  add_index "viator_events", ["iata_code"], :name => "viator_airport_code"

end
