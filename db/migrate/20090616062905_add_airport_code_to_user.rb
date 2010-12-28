class AddAirportCodeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :home_airport_code, :string, :limit => 3
    add_column :cities, :airport_code, :string, :limit => 3
  end

  def self.down
    remove_column :users, :home_airport_code
    remove_column :cities, :airport_code
  end
end
