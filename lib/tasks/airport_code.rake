require 'rss'  

namespace :airport_code do
    
  desc "Insert airport code into tables 'cities'"
  task :insert => :environment do

    for i in (5..242)
      city = City.find_by_id(i)
      unless city.nil?
        city_name = city.city_country
        city_name.gsub!(',','')
        city_name.gsub!(' ','+')
        puts "city id="+i.to_s
        puts "Requesting http://api.mobissimo.com/airportlookupapi.php?name=#{city_name}"
        xml = open("http://api.mobissimo.com/airportlookupapi.php?name=#{city_name}").read

        doc = REXML::Document.new(xml)
        unless doc.root.elements[1].nil?
          a_code = doc.root.elements[1].attributes["airportcode"]
          puts "Found " + a_code
          city.airport_code = a_code
          city.save!
        end
        sleep 0.5
      end
    end
  end
end