class CreateCheckIns < ActiveRecord::Migration
  def self.up
    create_table :check_ins do |t|
      t.integer :city_id, :null => false
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :check_ins
  end
end
