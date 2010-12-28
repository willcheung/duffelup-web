class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :user_id, :trip_id, :null => false
      t.datetime :favorited_at
    end
  end

  def self.down
    drop_table :favorites
  end
end
