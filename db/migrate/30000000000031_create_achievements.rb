class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.references :users
      t.references :stamps
      
      t.timestamps
    end
  end

  def self.down
    drop_table :achievements
  end
end
