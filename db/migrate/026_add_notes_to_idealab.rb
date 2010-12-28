class AddNotesToIdealab < ActiveRecord::Migration
  def self.up
    add_column :idealabs, :notes, :text
  end

  def self.down
    remove_column :idealabs, :notes
  end
end
