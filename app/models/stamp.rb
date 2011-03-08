class Stamp < ActiveRecord::Base
  belongs_to :landmark
  has_many :achievements, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :image_url
end
