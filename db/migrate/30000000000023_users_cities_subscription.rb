class UsersCitiesSubscription < ActiveRecord::Migration
  def self.up
    # Used for subscription to deals and "following"
    create_table :cities_users, :id => false do |t|
      t.integer :city_id, :null => false
      t.integer :user_id, :null => false
    end
    
    add_column :users, :source, :string, :limit => 20
  end

  def self.down
    drop_table :cities_users
    remove_column :users, :source
  end
end
