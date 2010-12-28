class CreateFeaturedDuffels < ActiveRecord::Migration
  def self.up
    create_table :featured_duffels do |t|
      t.string  :title, :null => false
      t.string  :permalink, :null => false
      t.integer :city_id, :null => false
      t.string  :city_country, :null => false
      t.integer :user_id, :null => false
      t.integer :trip_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :featured_duffels
  end
end
