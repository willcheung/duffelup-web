class AddEmailUpdateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_updates, :integer
  end

  def self.down
    remove_column :users, :email_updates
  end
end
