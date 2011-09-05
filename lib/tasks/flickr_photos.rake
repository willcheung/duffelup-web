namespace :flickr_photos do
    
  desc "Retrieve Flickr Photos for top 100 cities"
  task :pull => :environment do
    flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
    cities = City.find(:all, :select => "id, city_country", :conditions => "rank = 1 or rank = 2")
    
    cities.each do | city |
      s = city.city_country.gsub(', HI, United States', '')
      s = s.gsub(', United States', '')
      words = s.split(" ")
      words = words.collect do |word|
          word = Iconv.iconv('ascii//translit', 'utf-8', word).to_s
          word = word.gsub(/\W/,'')
      end
      tag = words.join(" ").gsub(" ", "-").downcase
      
      puts "Deleting previous records of this city"
      FlickrPhoto.connection.execute("delete from flickr_photos where city_id = #{city.id}")
      
      puts "Search tag: " + tag
      
      photos = flickr.photos.search(:tags => tag, :license => "4,5,6,7", :per_page => 150, :media => 'photo', :page => 1, :sort => 'interestingness-desc')
      
      photos.each do | p |
        photo = FlickrPhoto.new(:city_id => city.id, 
                                :title => p.title, 
                                :owner_name => p.owner_name, 
                                :photo_url => p.url_photopage, 
                                :url_square => p.url(:square), 
                                :url_small => p.url(:small))
        photo.save!
      end
      sleep 3
    end
  end
end