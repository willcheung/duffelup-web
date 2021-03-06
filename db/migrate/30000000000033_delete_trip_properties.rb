class DeleteTripProperties < ActiveRecord::Migration
  def self.up
    drop_table :trip_properties
  end
  
  def self.down
    create_table :trip_properties do |t|
      t.integer :trip_id
      t.text :custom_css
      t.integer :custom_header_label, :limit => 1, :default => 1
      t.string :itinerary_header
      t.string :itinerary_labels
      t.timestamps
    end
  end
end
