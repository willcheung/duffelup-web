class ApiKey < ActiveRecord::Base
  require "digest/sha1"
  
  belongs_to :user
  
  def self.check_api_key(user, source)
    key = self.find_by_user_id_and_source(user.id, source)
    unless key
      key = ApiKey.new
      key.generate_api_key(user, source)
    end
    
    return key
  end

  def generate_api_key(user, source, length=30)
    if source == "iphone"
      # iphone key authorizes user to see their own private duffels!!
      self.key = Digest::SHA1.hexdigest("#{user.username}-#{user.crypted_password}-greatest-iphone-app!")[1..length]
    elsif source == "widget"
      self.key = Digest::SHA1.hexdigest(Time.now.to_s + rand(88168).to_s)[1..length]
    end
    
    self.user_id = user.id
    self.source = source
    save(false)
  end
  
end
