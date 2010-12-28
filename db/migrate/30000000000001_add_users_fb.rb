class AddUsersFb < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_user_id, :integer
    add_column :users, :email_hash, :string
    change_column :users, :crypted_password, :string, :limit => 40, :null => true
    change_column :users, :salt, :string, :limit => 40, :null => true
    execute("alter table users modify fb_user_id bigint")
  end

  def self.down
    remove_column :users, :fb_user_id
    remove_column :users, :email_hash
    change_column :users, :crypted_password, :null => false
    change_column :users, :salt, :null => false
  end

end
