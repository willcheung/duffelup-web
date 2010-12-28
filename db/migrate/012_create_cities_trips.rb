class CreateCitiesTrips < ActiveRecord::Migration
  def self.up
    create_table :cities_trips, :id => false do |t|
      t.integer :city_id, :null => false
      t.integer :trip_id, :null => false
    end
  end

  def self.down
    drop_table :cities_trips
  end
end
