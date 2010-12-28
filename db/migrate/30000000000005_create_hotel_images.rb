class CreateHotelImages < ActiveRecord::Migration
  def self.up
    create_table :hotel_images do |t|
      t.integer :hotel_id
      t.string  :name
      t.string  :caption
      t.string  :url
      t.string  :thumb_url
    end
    
    add_index :hotel_images, [:hotel_id]
  end

  def self.down
    drop_table :hotel_images
  end
end
