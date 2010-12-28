class RemoveMiscColumns < ActiveRecord::Migration
  def self.up
    remove_column :users, :wishlist
    remove_column :ideas, :transport
    remove_column :ideas, :created_at
    remove_column :ideas, :updated_at
    remove_column :ideas, :hours
    remove_column :transportations, :created_at
    remove_column :transportations, :updated_at
  end

  def self.down
    add_column :users, :wishlist, :string
    add_column :ideas, :transport, :string
    add_column :ideas, :hours, :string
    add_column :ideas, :updated_at, :datetime
    add_column :ideas, :created_at, :datetime
    add_column :transportations, :updated_at, :datetime
    add_column :transportations, :created_at, :datetime
  end
end
