class Stamp < ActiveRecord::Base
  belongs_to :landmark
  has_many :achievements, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :image_url
  
  def to_xml(options = {}, &block)
    defaults = {:include => :landmark}
    options.merge!(defaults) do |key, oldval, newval|
      case oldval.class
      when Hash then oldval.merge(newval => {})
      else [newval].push(oldval).compact.uniq.flatten
      end
    end
    super
  end
  
end
