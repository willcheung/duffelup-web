class AddLatLngToIdeas < ActiveRecord::Migration
  def self.up
    add_column :ideas, :lat, :decimal, :precision => 15, :scale => 10
    add_column :ideas, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :ideas, :lat
    remove_column :ideas, :lng
  end
end
