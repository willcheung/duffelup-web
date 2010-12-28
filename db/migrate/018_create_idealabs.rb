class CreateIdealabs < ActiveRecord::Migration
  def self.up
    create_table :idealabs do |t|
      t.integer :city_id, :null => false # foreign key to City
      t.string  :idea_type # (Hotels, Restaurants, Activities)
      t.string  :title, :phone, :address, :transport, :website, :hours, :price_range
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
      t.string  :source # source url
      t.integer :copy_count
      t.integer :contributed_by # foriegn key to User
      t.timestamps
    end
    
    # Not going to miss these
    remove_column :ideas, :is_public
    remove_column :ideas, :price_range
    remove_column :ideas, :edited_by
  end

  def self.down
    drop_table :idealabs
  end
end
