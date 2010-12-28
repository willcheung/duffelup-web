class AddHideTourToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hide_tour_at, :datetime
  end

  def self.down
    remove_column :users, :hide_tour_at
  end
end
