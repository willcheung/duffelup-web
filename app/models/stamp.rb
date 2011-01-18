class Stamp < ActiveRecord::Base
  belongs_to :landmark
  has_many :achievements, :dependent => :destroy
end
