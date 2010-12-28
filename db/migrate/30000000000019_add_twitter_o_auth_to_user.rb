class AddTwitterOAuthToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
    remove_column :users, :invitation_limit
    add_column :users, :bandwidth, :integer, :default => 0
  end

  def self.down
    remove_column :users, :twitter_token
    remove_column :users, :twitter_secret
    remove_column :users, :bandwidth
    add_column :users, :invitation_limit, :integer
  end
end

