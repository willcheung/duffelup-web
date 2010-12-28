class AddDescriptionToGuides < ActiveRecord::Migration
  def self.up
    add_column :guides, :description, :text
    add_column :landmarks, :image_url, :string
  end

  def self.down
    remove_column :guides, :description
    remove_column :landmarks, :image_url
  end
end
