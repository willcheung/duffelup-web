class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.integer  :country_id, :null => false
      t.string  :region
      t.string  :city
      t.float   :latitude
      t.float   :longitude
      t.string  :city_country
    end
    
    add_index :cities, [:city_country], :name => "city_country_optimization"
    
    execute "LOAD DATA LOCAL INFILE '#{RAILS_ROOT}/db/cities.txt' INTO TABLE cities " + 
            "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY \"\"\"\" LINES TERMINATED BY '\n' " + 
            "(id, country_id, region, city, latitude, longitude, city_country);"
    
    #execute "ALTER IGNORE TABLE cities ADD UNIQUE INDEX(city, region, country_id);"
  end

  def self.down
    drop_table :cities
  end
end
