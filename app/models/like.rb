class Like < ActiveRecord::Base
   belongs_to :user
   belongs_to :event

   validates_uniqueness_of :event_id, :scope => :user_id
   validates_presence_of :user
   validates_presence_of :event

   def self.count_likes(events)
     likes = Hash.new
     
     tmp = Like.find_by_sql("SELECT event_id, count(`likes`.id) AS count_all 
                        FROM `likes` 
                        WHERE (`likes`.event_id in 
                            (#{events.map(&:id).join(',')})) 
                        group by likes.event_id;")
                        
      tmp.each do |l|
        likes[l.event_id] = l.count_all
      end
      
      return likes
   end

end
