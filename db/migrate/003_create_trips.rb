class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.string    :title, :permalink, :null => false
      t.date      :start_date, :end_date
      t.integer   :duration, :null => false
      t.text      :description, :null => false
      t.integer   :is_public, :default => 1, :null => false
      t.string    :destination, :null => false
      t.integer   :active, :default => 0, :null => false
      t.integer   :can_invite_friends, :default => 1, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
