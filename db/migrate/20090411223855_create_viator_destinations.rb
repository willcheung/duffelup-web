class CreateViatorDestinations < ActiveRecord::Migration
  def self.up
    create_table :viator_destinations do |t|
      t.string  :destination_name
      t.string  :destination_type
      t.integer :parent_id
      t.string  :parent_name
      t.string  :iata_code
      t.string  :destination_url
      t.timestamps
    end
  end

  def self.down
    drop_table :viator_destinations
  end
end
