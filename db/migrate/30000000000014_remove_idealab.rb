class RemoveIdealab < ActiveRecord::Migration
  def self.up
    add_column :hotels, :url, :string
    add_column :hotels, :image_url, :string
    add_column :hotels, :currency, :string, :limit => 3
    add_column :hotels, :rank, :integer, :limit => 1
    change_column :cities, :rank, :integer, :limit => 1
    drop_table :idealabs
  end

  def self.down
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
  end
end
