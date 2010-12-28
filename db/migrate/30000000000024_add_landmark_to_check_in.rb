class AddLandmarkToCheckIn < ActiveRecord::Migration
  def self.up
    add_column :check_ins, :landmark_id, :integer
    add_index :check_ins, :landmark_id
  end

  def self.down
    remove_index :check_ins, :landmark_id
    remove_column :check_ins, :landmark_id
  end
end
