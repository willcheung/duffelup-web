class AddAddressToLandmarks < ActiveRecord::Migration
  def self.up
    add_column :landmarks, :address, :string
  end

  def self.down
    remove_column :landmarks, :address
  end
end
