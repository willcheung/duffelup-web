class AddLandmarkToStamps < ActiveRecord::Migration
  def self.up
    add_column :stamps, :landmark_id, :integer
    add_index :stamps, :landmark_id
    remove_column :check_ins, :landmark_id
    
    add_column :achievements, :user_id, :integer
    add_column :achievements, :stamp_id, :integer
    remove_column :achievements, :users_id
    remove_column :achievements, :stamps_id
  end

  def self.down
    add_column :check_ins, :landmark_id, :integer
    remove_index :stamps, :landmark_id
    remove_column :stamps, :landmark_id
  end
end