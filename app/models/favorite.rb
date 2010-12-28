class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :trip
  
  validates_presence_of :user, :trip
  
  # Return true if the user favorited this trip.
  def self.exists?(user, trip)
    not find_by_user_id_and_trip_id(user, trip).nil?
  end
  
  def self.unfavorite(user, trip)
    transaction do
      destroy(find_by_user_id_and_trip_id(user, trip))
    end
  end
  
  # Favoriting a trip as user
  def self.fav(user, trip)
    unless Favorite.exists?(user.id, trip.id)
      create(:user => user, :trip => trip, :favorited_at => Time.now)
    end
  end
  
  def self.count_favorites(trips)
    unless trips.empty?
      trips_hash = {}
      trips_ids_array = []
    
      trips.each do |t|
        trips_ids_array << t.id.to_s
      end
      
      count = self.find_by_sql("select *, count(id) as count
                            from favorites 
                            where trip_id in (#{trips_ids_array.join(',')})
                            group by trip_id")
                            
      count.each do |c|
        trips_hash["#{c.trip_id.to_s}"] = c.count
      end
      
      return trips_hash
    end
    []
  end
  
end
