class CreateViatorEvents < ActiveRecord::Migration
  def self.up
    create_table :viator_events do |t|
      t.string  :product_code
      t.string  :product_name
      t.text    :introduction
      t.string  :duration
      t.string  :product_image
      t.string  :product_image_thumb
      t.integer :viator_destination_id
      t.string  :country
      t.string  :region
      t.string  :city
      t.string  :iata_code
      t.string  :product_url
      t.string  :price
      t.string  :avg_rating
      t.timestamps
    end
  end
  
  # insert into cities table because of Viator's City is different
  # insert into cities values(199454, 230, "HI", "Maui", 20.801, -156.333, "Maui, HI, United States");
  # insert into cities values(199455, 230, "HI", "Oahu", 21.466667, -157.966667, "Oahu, HI, United States");
  # insert into cities values(199456, 230, "HI", "Kauai", 22.05, -159.5, "Kauai, HI, United States");
  # insert into cities values(199457, 230, "HI", "Big Island", 19.516667, -155.533333, "Big Island, HI, United States");

  def self.down
    drop_table :viator_events
  end
end
