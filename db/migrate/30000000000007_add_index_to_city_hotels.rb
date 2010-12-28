class AddIndexToCityHotels < ActiveRecord::Migration
  def self.up
    add_index :hotels, [:city]
    add_index :hotels, [:country]
    add_index :hotels, [:state]
    add_index :cities, [:city]
    add_index :cities, [:region]
  end

  def self.down
  end
end
