class DeleteCityFromIdeas < ActiveRecord::Migration
  def self.up
    remove_column :ideas, :city_country 
  end

  def self.down
    add_column :ideas, :city_country, :string
  end
end
