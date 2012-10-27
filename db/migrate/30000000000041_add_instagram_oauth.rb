class AddInstagramOauth < ActiveRecord::Migration
  def self.up
    add_column :users, :instagram_token, :string
  end

  def self.down
    remove_column :users, :instagram_token
  end
end
