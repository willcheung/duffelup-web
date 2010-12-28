class ChangeEventDescription < ActiveRecord::Migration
  def self.up
    change_column :events, :note, :text, :null => false
  end

  def self.down
    change_column :events, :note, :string, :limit => 200
  end
end
