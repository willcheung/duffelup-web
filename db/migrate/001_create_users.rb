class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string    :username, :null => false
      t.string    :email, :null => false
      t.string    :full_name
      t.string    :crypted_password, :salt, :limit => 40, :null => false
      t.timestamps
      t.string    :remember_token
      t.datetime  :remember_token_expires_at
      t.string    :home_city
      t.integer   :city_id, :null => false, :default => 0
      t.string    :wishlist, :bio, :homepage
      t.integer   :active, :default => 1, :null => false
    end
  end

  def self.down
    drop_table :users
  end
end
