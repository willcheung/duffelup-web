require 'rss'
require 'contacts'
require 'hpricot'

class WebApp < ActiveResource::Base
  
  IPHONE_API_TOKEN = "c00l3stiPhoneApp-7c4465b3f951effdfa708a66300e9721dc637a53"
  
  def self.consume_rss_feed(url)
    rss = RSS::Parser.parse(open(url).read, false)
  rescue OpenURI::HTTPError
    return nil
  rescue Timeout::Error
    return nil
  rescue Errno::ETIMEDOUT
    return nil
  end
  
  def self.consume_xml_from_url(url)
    doc = Hpricot::XML(open(url).read)
  rescue OpenURI::HTTPError
    return ""
  rescue Timeout::Error
    return ""
  rescue Errno::ETIMEDOUT
    return ""
  end
  
  def self.shorten_url(url)
    request = "http://api.bitly.com/v3/shorten?format=json&longUrl="+url+"&login=duffel&apiKey=R_9a51ef0e67348addd7800532097a4a3e"
    # request = "http://api.bit.ly/shorten?version=2.0.1&longUrl="+url+"&login=duffel&apiKey=R_9a51ef0e67348addd7800532097a4a3e"
    r = ActiveSupport::JSON.decode(open(request).read)
    short_url = r["data"]["url"]
    
    if short_url
      return short_url
    else
      return url
    end
  end
  
  ##############
  # Facebook
  ##############
  
  #  Automatically publish stream to fb, even when user is offline
  def self.post_stream_on_fb(fb_user_id, action_url, msg, action_text, attachment=nil)
    f = Facebooker::Session.create
    
    f.post('facebook.stream.publish', 
            :uid => fb_user_id, 
            :target_id => fb_user_id,
            :message => msg, 
            :attachment => attachment,
            :action_links => [:text => action_text, :href => action_url])
  
  rescue Facebooker::Session::PermissionError
    return
  rescue Facebooker::Session::TooManyUserActionCalls
    return
  end
  
  def self.setup_fb_action_links(trip, trip_url)
    "[{'text' : 'Check out my trip', 'href' : '#{trip_url}'}]"
  end
  
  def self.setup_fb_check_in_attachments(title, href, note, image_url)
    "{'name': '#{title}',
      'href': '#{href}',
      'caption': 'duffelup.com',
      'description': '#{note}',
      'media': [{'type': 'image', 
                  'src': '#{image_url}',
                  'href': '#{href}'}
                ]}"
  end
  
  def self.setup_fb_trip_attachments(trip, trip_url)
    if !trip.photo.size.nil? and trip.photo.size != ""
      image = trip.photo.url(:thumb)
    else
      image = "http://duffelup-assets.s3.amazonaws.com/logos/iphone4Icon.png"
    end
    
    "{'name': '#{trip.title}',
      'href': '#{trip_url}',
      'description': '#{trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" ")}',
      'media': [{'type': 'image', 
                  'src': '#{image}',
                  'href': '#{trip_url}'}
                ]}"
  end
  
  ###############
  # Email import
  ###############
  
  def self.import_contacts(email, password)
    if email.include?("gmail.com")
      site = Contacts::Gmail
    elsif email.include?("yahoo.com")
      site = Contacts::Yahoo
    elsif email.include?("hotmail.com")
      site = Contacts::Hotmail
    else
      return []
    end
    
    return site.new(email, password).contacts
  end
end