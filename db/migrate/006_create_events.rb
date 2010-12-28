class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :trip_id, :null => false              # foreign key for Trip
      t.integer :eventable_id                         # foreign key to various Ideas & Events
      t.string  :eventable_type
      t.integer :position, :null => false             # for acts_as_list
      t.integer :list, :null => false, :default => 0  # for maintaining multiple lists (aka "days") in the itinerary.  0 = unschedule, 1 = Day 1, etc.
      t.string  :title, :null => false                # custom title for this event
      t.string  :note, :limit => 200                 # short note, no more than 200 characters long
    end
  end

  def self.down
    drop_table :events
  end
end
