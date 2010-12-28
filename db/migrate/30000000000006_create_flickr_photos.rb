class CreateFlickrPhotos < ActiveRecord::Migration
  def self.up
    create_table :flickr_photos do |t|
      t.integer :city_id
      t.string  :title
      t.string  :owner_name
      t.string  :photo_url
      t.string  :url_square
      t.string  :url_small
    end
  end

  def self.down
    drop_table :flickr_photos
  end
end
