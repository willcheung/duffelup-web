class CheckIn < ActiveRecord::Base
  has_one :event, :as => :eventable
  belongs_to :city
  # belongs_to :landmark
  
  validates_presence_of :city_id
  validates_associated :event
  validate :event_must_be_present
  validate :upload_limit_reached
  
  acts_as_mappable
  
  attr_accessor :recently_achieved
  
  # will_paginate results per page
  cattr_reader :per_page
  @@per_page = 10
  
  before_validation_on_create do |check_in|
    check_in.city = CheckIn.find_city check_in.lat, check_in.lng
    # check_in.landmark = CheckIn.find_landmark check_in.lat, check_in.lng
    check_in.award_stamp
    check_in.slot_into_itinerary
  end
  
  def self.find_city(lat, lng)
    return nil unless lat && lng
    res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{lat},#{lng}"
    city = City.find_closest(:origin => [lat, lng], :within => 50,
      :conditions => ["LCASE(city_country) like ?", "#{res.city.downcase}%"]) if res.city
    city = City.find_closest(:origin => [lat, lng], :conditions => "city <> ''") unless city
    city
  end
  
  def self.find_landmark(lat, lng)
    return nil unless lat && lng
    Landmark.find_closest(:origin => [lat, lng], :within => 0.5)
  end
  
  def slot_into_itinerary
    now = Time.now
    if event.trip.start_date and event.trip.end_date and now >= event.trip.start_date
      event.trip.start_date.upto(event.trip.end_date) do |d|
        if now < d + 1.day
          event.list = (d + 1.day) - event.trip.start_date
          break
        end
      end
    end
  end
  
  def award_stamp
    landmark = CheckIn.find_landmark(lat, lng)
    stamp = landmark && landmark.stamp
    if stamp && !event.user.stamps.include?(stamp)
      event.user.achievements.create(:stamp => stamp)
      self.recently_achieved = stamp
    end
  end
  
  def event_must_be_present
    errors.add(:event, 'must be present') if event.blank?
  end
  
  def upload_limit_reached
    errors.add(:event, 'photo limit reached') if event.user.bandwidth >= User::UPLOAD_LIMIT
  end
  
  def to_xml(options = {}, &block)
    defaults = {:procs => Proc.new { |opt| self.recently_achieved.to_xml(:builder => opt[:builder],
      :skip_instruct => true) if self.recently_achieved }, :include => { :event => { :include => {
        :user => { :only => [:full_name, :username, :avatar_file_name ] }} } } }
    options.merge!(defaults) do |key, oldval, newval|
      case oldval.class
      when Hash then oldval.merge(newval => {})
      else [newval].push(oldval).compact.uniq.flatten
      end
    end
    super
  end
end