class AddPhotoUrlToActivitiesFeeds < ActiveRecord::Migration
  def self.up
    add_column :activities_feeds, :photo_url, :string, :null => false
    add_column :activities_feeds, :title, :string, :null => false
  end

  def self.down
    remove_column :activities_feeds, :photo_url
    remove_column :activities_feeds, :title
  end
end
