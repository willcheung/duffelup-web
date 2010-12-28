class AddPriceRangeToIdeas < ActiveRecord::Migration
  def self.up
    add_column :ideas, :price_range, :integer, :limit => 1
    change_column :users, :email_updates, :integer, :default => 1, :limit => 1
  end

  def self.down
    remove_column :ideas, :price_range
  end
end
