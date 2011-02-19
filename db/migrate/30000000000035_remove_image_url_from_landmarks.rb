class RemoveImageUrlFromLandmarks < ActiveRecord::Migration
  def self.up
    remove_column :landmarks, :image_url
    remove_column :guides, :is_free
  end

  def self.down
    add_column :landmarks, :image_url, :string
    add_column :guides, :is_free, :boolean
  end
end
