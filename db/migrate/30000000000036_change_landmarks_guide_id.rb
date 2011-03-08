class ChangeLandmarksGuideId < ActiveRecord::Migration
  def self.up
    change_column :landmarks, :guide_id, :integer, :null => true
  end

  def self.down
    change_column :landmarks, :guide_id, :integer, :null => false
  end
end