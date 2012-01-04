class ChangePredicateActivitiesFeed < ActiveRecord::Migration
  def self.up
    change_column :activities_feeds, :predicate, :text
  end

  def self.down
    change_column :activities_feeds, :predicate, :string
  end
end
