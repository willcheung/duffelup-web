class Landmark < ActiveRecord::Base
  belongs_to :city
  has_one :stamp, :dependent => :destroy
  
  acts_as_mappable
  
  validates_presence_of :city_id
  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  
end
