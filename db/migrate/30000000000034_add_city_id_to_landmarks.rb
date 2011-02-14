class AddCityIdToLandmarks < ActiveRecord::Migration
  def self.up
    add_column :landmarks, :city_id, :integer
    
    add_column :stamps, :image_url, :string
  end

  def self.down
    remove_column :stamps, :image_url
    remove_column :landmarks, :city_id
  end
end