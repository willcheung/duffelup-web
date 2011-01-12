class Achievement < ActiveRecord::Base
  belongs_to :user
  belongs_to :stamp
  
  validates_presence_of :user
  validates_presence_of :stamp
end
