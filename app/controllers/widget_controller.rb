# Copied and tweaked from http://www.igvita.com/2007/06/05/creating-javascript-widgets-in-rails/
class WidgetController < ApplicationController
  layout nil
  session :off
 
  skip_before_filter :detect_user_agent
  skip_before_filter :login_from_cookie
  skip_before_filter :meta_defaults
  
  before_filter :validate_api_key, :except => :add_to_duffel
 
  def duffel_badge
    if !fragment_exist?("api_badge-#{@key.key}", :time_to_live => 1.hour)
      @user = User.find_by_id(@key.user_id)
      @trips = Trip.load_trips_for_widgets_and_comments_count(@key.user_id)
    end
  end
  
  def duffel_widget
    if !fragment_exist?("api_widget-#{@key.key}", :time_to_live => 1.hour)
      @user = User.find_by_id(@key.user_id)
      @trips = Trip.load_trips_for_widgets_and_comments_count(@key.user_id)
      
      if @user.avatar.exists?
        @avatar_url = "http://duffelup.com" + @user.avatar.url(:thumb)
      elsif !@user.avatar_file_name.nil? 
        @avatar_url = @user.avatar_file_name
      else
        @avatar_url = "../images/icon-user.png"
      end
    end
  end
  
  def duffel_text
    if !fragment_exist?("api_text-#{@key.key}", :time_to_live => 1.hour)
      @user = User.find_by_id(@key.user_id)
      @trips = Trip.load_trips_for_widgets_and_comments_count(@key.user_id)
    end
  end
  
  def add_to_duffel
    
  end

protected
  def validate_api_key
    # validate the key against database
    @key = ApiKey.find_by_key(params[:api_key])
    
    if not @key or @key.source != "widget"
      return render(:text => "document.write('Invalid API key.')") 
    end
      
  end
end