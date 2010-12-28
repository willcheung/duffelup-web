class AddRankToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :rank, :integer
  end

  def self.down
    remove_column :cities, :rank
  end
end
