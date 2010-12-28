class CreateHotels < ActiveRecord::Migration
  def self.up
    create_table :hotels do |t|
      t.string  :name
      t.string  :airport_code, :limit => 3
      t.string  :address1
      t.string  :address2
      t.string  :address3
      t.string  :city
      t.string  :state
      t.string  :country
      t.decimal :longitude, :precision => 11, :scale => 6
      t.decimal :latitude, :precision => 11, :scale => 6
      t.float   :low_rate
      t.float   :high_rate
      t.integer :marketing_level
      t.integer :confidence
      t.text    :description
    end
    
    add_index :hotels, [:airport_code], :name => "hotels_airport_code"
    add_index :viator_events, [:iata_code], :name => "viator_airport_code"
    add_index :cities, [:airport_code], :name => "cities_airport_code"
  end

  def self.down
    drop_table :hotels
  end
end
