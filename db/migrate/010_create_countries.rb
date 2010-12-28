class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :country_code, :limit => 2
      t.string :country_name
    end
    
    execute "LOAD DATA LOCAL INFILE '#{RAILS_ROOT}/db/countries.txt' INTO TABLE countries " + 
            "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY \"\"\"\" LINES TERMINATED BY '\n' (id, country_code, country_name);"
  
  end

  def self.down
    drop_table :countries
  end
end
