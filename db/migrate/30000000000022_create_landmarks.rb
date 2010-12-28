class CreateLandmarks < ActiveRecord::Migration
  def self.up
    create_table :landmarks do |t|
      t.integer :guide_id, :null => false
      t.string :name, :limit => 50
      t.text :description
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :landmarks
  end
end
