class Landmark < ActiveRecord::Base
  belongs_to :guide
  has_one :stamp
  
  acts_as_mappable
  
  validates_presence_of :guide_id
  validates_presence_of :name
  validates_length_of :name, :maximum => 50
end
