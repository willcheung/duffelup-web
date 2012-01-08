class ChangeTripInNewsFeed < ActiveRecord::Migration
  def self.up
    change_column :activities_feeds, :trip, :text
    change_column :activities_feeds, :actor, :text
  end

  def self.down
    change_column :activities_feeds, :trip, :string
    change_column :activities_feeds, :trip, :string
  end
end
