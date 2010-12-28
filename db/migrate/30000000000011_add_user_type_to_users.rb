class AddUserTypeToUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :active, :category
    change_column :users, :email_updates, :integer, :default => 1
  end

  def self.down
    rename_column :users, :category, :active
  end
end
