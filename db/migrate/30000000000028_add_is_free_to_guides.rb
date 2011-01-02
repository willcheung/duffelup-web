class AddIsFreeToGuides < ActiveRecord::Migration
  def self.up
    add_column :guides, :is_free, :boolean, :default => 0
    rename_column :guides, :published, :is_published
  end

  def self.down
    rename_column :guides, :is_published, :published
    drop_column :guides, :is_free
  end
end
