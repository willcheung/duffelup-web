class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.datetime :acted_on
      t.references :user
      t.references :event
      t.timestamps
    end
    
    add_index :likes, :user_id
    add_index :likes, :event_id
  end

  def self.down
    drop_table :likes
  end
end
