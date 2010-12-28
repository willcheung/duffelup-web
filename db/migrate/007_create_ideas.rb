class CreateIdeas < ActiveRecord::Migration
  def self.up
    create_table :ideas do |t|
      t.integer :city_id, :null => false # foreign key to City
      t.string  :type # For Single Table Inheiritance (Hotels, Restaurants, Activities)
      t.string  :title, :phone, :address, :transport, :website, :hours, :city_country
      t.integer :price_range
      t.integer :is_public, :default => 0, :null => false
      t.integer :edited_by # foriegn key to User
      t.timestamps
    end
  end

  def self.down
    drop_table :ideas
  end
end
