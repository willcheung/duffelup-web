class AddColumnsToActivitiesFeed < ActiveRecord::Migration
  def self.up
    add_column  :activities_feeds, :actor, :string
    add_column  :activities_feeds, :trip_id, :integer, :null => true
    rename_column  :activities_feeds, :body, :trip
    add_column  :activities_feeds, :action, :integer, :limit => 2
    add_column  :activities_feeds, :is_public, :integer, :limit => 1
    add_column  :activities_feeds, :predicate, :string
    remove_column :activities_feeds, :updated_at
  end

  def self.down
    remove_column  :activities_feeds, :actor
    remove_column  :activities_feeds, :trip_id
    rename_column  :activities_feeds, :trip, :body
    remove_column  :activities_feeds, :action
    remove_column  :activities_feeds, :is_public
    remove_column  :activities_feeds, :predicate
    add_column :activities_feeds, :updated_at, :timestamp
  end
end
