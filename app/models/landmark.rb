class Landmark < ActiveRecord::Base
  belongs_to :city
  has_one :stamp, :dependent => :destroy
  
  acts_as_mappable
  
  validates_presence_of :city_id
  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  
  def to_xml(options = {}, &block)
    defaults = {:include => :city}
    options.merge!(defaults) do |key, oldval, newval|
      case oldval.class
      when Hash then oldval.merge(newval => {})
      else [newval].push(oldval).compact.uniq.flatten
      end
    end
    super
  end
  
end
