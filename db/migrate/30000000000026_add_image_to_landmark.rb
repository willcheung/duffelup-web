class AddImageToLandmark < ActiveRecord::Migration
  def self.up
    add_column :landmarks, :fun_facts, :text
    add_column :landmarks, :tips, :text
    add_column :guides, :published, :boolean, :default => 0
    add_column :guides, :fun_facts, :text
  end

  def self.down
    remove_column :landmarks, :fun_facts
    remove_column :landmarks, :tips
    remove_column :guides, :published
    remove_column :guides, :fun_facts
  end
end
