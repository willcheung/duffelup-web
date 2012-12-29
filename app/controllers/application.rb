# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base 
  include AuthenticatedSystem
  include ExceptionNotifiable
  include ApplicationHelper
  
  self.allow_forgery_protection = false
  skip_before_filter :verify_authenticity_token
  
  before_filter :meta_defaults
  before_filter :detect_user_agent, :except => :browser_error
  before_filter :login_from_cookie
  
  before_filter :handle_IE_session #Rails and IFrames - Issues with Internet Explorer sessions (http://www.sympact.net/2008/07/rails-and-ifram.html)
  
  helper :all # include all helpers, all the time
  
  # rescue_from Twitter::Unauthorized, :with => :force_sign_in

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery :except => [:auto_complete_for_trip_destination, :hide_announcement] # :secret => 'f6bc72eb48447524d2ff9fcf464c1dc3'
  
  session :off, :if => proc { |request| Utility.robot?(request.user_agent) }
  
  #prepend_before_filter do |controller|
  #  controller.class.allow_forgery_protection = false #controller.session_enabled?
  #end
  
  FBSession = Struct.new(:uid, :access_token)
  
  def to_json(*options)
    ActiveSupport::JSON.encode(self, options)
  end
  
  def param_posted?(sym)
    request.post? and params[sym]
  end
  
  def build_sortable_list_containment(trip)
    # "Board" is always on the list
    list_containment = ["'board'"]
    
    # each "itinerary_list" represents a day on a trip.
    (trip.duration+1).times do |i|
      list_containment.push("'itinerary_list_" + (i+1).to_s + "'")
    end
    
    return list_containment
  end
  
  # takes an array of string and return a string of list with comma and "and"
  def username_list_helper(array)
    if array.size == 0 or array.size == 1
      return fast_link(display_user_name(array[0]), "#{array[0].username}")
    elsif array.size == 2
      return fast_link(display_user_name(array[0]), "#{array[0].username}") + " and " + fast_link(display_user_name(array[1]), "#{array[1].username}")
    else
      index_minus_one = array.size - 2
      s = fast_link(display_user_name(array[0]), "#{array[0].username}")
      for i in (1..index_minus_one.to_i)
        s = s + ", " + fast_link(display_user_name(array[i]), "#{array[i].username}")
      end
      s = s + " and " + fast_link(display_user_name(array[array.size-1]), "#{array[array.size-1].username}")
      
      return s
    end
  end
  
  # Determines whether the trip is public or private.  This method, however, always returns true 
  # when users browse their own trips.
  def trip_is_public(trip, user)
    if (logged_in? and user.id == current_user.id) # User always sees his/her own trips
      return true
    else
      if trip.is_public == 1 # When browsing to other users page, user only sees public trips
        return true
      else
        return false
      end
    end
  end
  
  # Protect a page from unauthorized access.
  def protect
    unless logged_in?
      session[:return_to] = request.request_uri
      
      respond_to do |format|
        flash[:notice] = "Please log in first"
        format.html { redirect_to login_url }
        format.xml  { render :xml => { :error => "User must be logged in.", :status => :unprocessable_entity } }
      end
    end
  end
  
  def is_user_invited_to_trip
    if !(new_visitor_created_trip? or (!@users.nil? and @users.include?(current_user)))
      respond_to do |format|
        format.html { redirect_to(:controller => 'site', :action => 'permission_error') }
        format.xml  { render :xml => { :error => "Permission denied.", :status => :unprocessable_entity } }
      end
    end
  end
  
  def protect_admin_page
    if logged_in?
      if admin? # Admin privilege
        return true
      end
    end
    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  private
  
  ###### Facebook OAuth ########
  def fb_session
    if !session['fb_uid'].nil? and !session['fb_access_token'].nil?
      @fb_session ||= FBSession.new(session['fb_uid'], session['fb_access_token'])
    else
      @oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET)
      info = @oauth.get_user_info_from_cookies(cookies)
      session['fb_access_token'] = info["access_token"] if !info.nil?
      session['fb_uid'] = info["user_id"] if !info.nil?
    
      @fb_session = FBSession.new(session['fb_uid'], session['fb_access_token'])
    end
  end
  helper_method :fb_session
  
  ######## Twitter OAuth ###########
  def oauth_consumer
    @oauth_consumer ||= OAuth::Consumer.new(ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'], :site => 'http://api.twitter.com', :request_endpoint => 'http://api.twitter.com', :sign_in => true)
  end

  def twitter_client
    Twitter.configure do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token = session['atoken']
      config.oauth_token_secret = session['asecret']
    end
    @twitter_client ||= Twitter::Client.new
  end
  helper_method :twitter_client

  def force_sign_in(exception)
    reset_session
    flash[:error] = 'We encountered a problem retrieving your Twitter credentials. Please sign in again.'
    redirect_to new_session_path
  end
  
  # Use this to access the flickr API easily. You can type directly the flickr requests as they are described on the flickr website.
  # require 'flickraw'
  #
  # recent_photos = flickr.photos.getRecent
  # puts recent_photos[0].title
  def flickr; $flickraw ||= FlickRaw::Flickr.new end
  
  ########## Other Stuff ###########
  def admin?
    current_user.username == "will" or current_user.username == "duffelup"
  end
  
  # Source code from file vendor/rails/actionpack/lib/action_view/helpers/text_helper.rb, line 60
  def truncate(text, *args)
    options = args.extract_options!
    unless args.empty?
      options[:length] = args[0] || 30
      options[:omission] = args[1] || "..."
    end
    options.reverse_merge!(:length => 30, :omission => "...")

    if text
      l = options[:length] - options[:omission].mb_chars.length
      chars = text.mb_chars
      (chars.length > options[:length] ? chars[0...l] + options[:omission] : text).to_s
    end
  end
  
  def encode64(string)
    ActiveSupport::Base64.encode64(string)
  end
  
  def decode64(string)
    ActiveSupport::Base64.decode64(string)
  end
  
  def meta_defaults
    @meta_description = "Duffel trip planner organizes your travel plans on a visual corkboard. Start creating personalized travel guide with friends and family!"
    @title = "Organize Your Travel Itinerary and Plan with Friends - Duffel"
    @link = "http://duffelup.com/images/logo.png"
  end
  
  def detect_user_agent
    #if request.user_agent =~ /(Opera|MSIE 6)/i and cookies[:browser_error] != "displayed"
    if request.user_agent =~ /(Opera)/i and cookies[:browser_error] != "displayed"
      cookies[:browser_error] = { :value => "displayed", :expires => 1.hour.from_now }
      redirect_to(:controller => 'site', :action => 'browser_error')
    end
  end
  
  class Utility
    def self.robot?(user_agent)
      user_agent =~ /(Baidu|bot|msnbot|Google|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)/i
    end
  end
  
  def handle_IE_session
    if request.user_agent =~ /(MSIE)/i
      response.headers['P3P'] = 'CP="CAO PSA OUR"'
    end
  end
  
end
