LOAD DATA LOCAL INFILE '/Users/wcheung/RailsApps/cities.txt' INTO TABLE cities FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY """" LINES TERMINATED BY '\n' (id, country_id, region, city, latitude, longitude, city_country);

LOAD DATA LOCAL INFILE '/Users/wcheung/RailsApps/countries.txt' INTO TABLE countries FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY """" LINES TERMINATED BY '\n' (id, country_code, country_name);

SELECT * INTO OUTFILE '/Users/wcheung/RailsApps/cities.txt' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'FROM cities;

ALTER IGNORE TABLE cities ADD UNIQUE INDEX(city, region, country_id);

create table cities_trips_dup like cities_trips;
insert cities_trips_dup select * from cities_trips;
rake db:migrate VERSION=10 # drop table
rake db:migrate VERSION # create table
insert cities_trips select * from cities_trips_dup;