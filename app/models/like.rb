class Like < ActiveRecord::Base
   belongs_to :user
   belongs_to :event

   validates_uniqueness_of :event_id, :scope => :user_id
   validates_presence_of :user
   validates_presence_of :event

end
