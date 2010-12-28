class Guide < ActiveRecord::Base
  has_many :landmarks
  belongs_to :city
  
  validates_presence_of :city_id
end
