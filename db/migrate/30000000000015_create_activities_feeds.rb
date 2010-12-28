class CreateActivitiesFeeds < ActiveRecord::Migration
  def self.up
    create_table :activities_feeds do |t|
      t.integer :user_id, :null => false
      t.string  :body
      t.timestamps
    end
  end

  def self.down
    drop_table :activities_feeds
  end
end
