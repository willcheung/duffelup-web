class UsersController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  
  layout "simple"
  
  before_filter :protect, :except => [:validate, :new, :create, :forgot_password, :auto_complete_for_user_home_city, :more_news_feed]
  
  def validate
    field = params[:field]
    user = User.new(field => params[:value])
    output = ""
    user.valid?
    if user.errors[field] != nil
      if user.errors[field].class == String
        output = "#{field.titleize} #{user.errors[field]}" 
      else
        output = "#{field.titleize} #{user.errors[field].to_sentence}" 
      end
    end
    render :text => output
  end

  def show
    @title = "Duffel Dashboard - Visual Bookmarking Tool and Trip Planner"
    @planned_trips = []
    @past_trips = []
    @no_date_trips = []
    @favorite_trips = []
    
    ####################################
    # Load Favorite trips
    ####################################
    # fragment cache user's favorites
    if !fragment_exist?("user-#{current_user.id}-favorites", :time_to_live => 1.day)
      fav_trips = Trip.find_favorites(current_user.id)
      fav_trips.each do |trip|
        @favorite_trips << trip if trip_is_public(trip, current_user)
      end
      write_fragment("user-#{current_user.id}-favorites", @favorite_trips)
    else
      @favorite_trips = read_fragment("user-#{current_user.id}-favorites")
    end
    
    # Count # of favorites for favorite trips
    if params[:tab] == "duffels-faves"
      @favorites_count = Favorite.count_favorites(@favorite_trips)
    end
    
    ####################################
    # Load Trips and Comments Count
    ####################################
    all_trips = Trip.load_trips_and_comments_count(current_user.id)
    
    ####################################
    # Find all (including favorites) trip admin and tripgoers
    ####################################
    t = all_trips.collect { |x| x.id } 
    t << @favorite_trips.collect { |x| x.id }
    t.flatten!
    @users_by_trip_id = User.find_users_by_trip_ids(t)
    
    # sort each duffel into three buckets: dateless, present, and past duffels
    all_trips.each do |trip|
      if trip.end_date.nil? or trip.start_date.nil?
        @no_date_trips << trip if trip_is_public(trip, current_user)
      elsif trip.end_date < Date.today
        @past_trips << trip if trip_is_public(trip, current_user)
      else
        @planned_trips << trip if trip_is_public(trip, current_user)
      end
    end
    
    # find favorite count for all trips (excluding favorites)
    if params[:tab] != "duffels-faves"
      @all_trips_favorite_count = Favorite.count_favorites(all_trips)
      
      # total favorite count on all the duffels
      unless @all_trips_favorite_count.nil?
        @total_favorite_count = 0
        @all_trips_favorite_count.each {|k,v| @total_favorite_count = @total_favorite_count + v.to_i }
      end

      # planned_trips will be in DESC order
      @planned_trips.reverse!

      # group past trips by year
      @past_trips_by_year = @past_trips.group_by {|e| e.start_date.year}
    end
    
    
    ####################################
    # Load Friends & Requested Friends
    ####################################
    if !fragment_exist?("#{current_user.username}-friends", :time_to_live => 1.week)
      @friends = User.load_all_confirmed_friends(current_user.id)
      write_fragment("#{current_user.username}-friends", @friends)
    else
      @friends = read_fragment("#{current_user.username}-friends")
    end
    @requested_friends = User.load_requested_friends(current_user.id)
    
    ####################################
    # Load Duffel of the Month
    ####################################
    if !fragment_exist?("dashboard-featured-duffel", :time_to_live => 1.day)
      @duffel_of_the_month = FeaturedDuffel.find(:first, :order => "created_at DESC")
    else
      @duffel_of_the_month = FeaturedDuffel.new
      @duffel_of_the_month = read_fragment("dashboard-featured-duffel")
    end
    
    ####################################
    # Load Duffel Blog RSS
    ####################################
    # if !fragment_exist?("dashboard-blog-rss", :time_to_live => 1.day)
    #       @blog_rss = WebApp.consume_rss_feed("http://blog.duffelup.com/rss")
    #       write_fragment("dashboard-blog-rss", @blog_rss) unless @blog_rss.nil?
    #     else
    #       @blog_rss = read_fragment("dashboard-blog-rss")
    #     end
    
    #######################################
    # Updates Tab - Load News Feed
    #######################################
    if (params[:tab]=="updates" and params[:subtab].nil?) or params[:tab].nil?
      @news_feed_with_total_pages = ActivitiesFeed.get_activities(@friends, params[:page], 40)
    elsif (params[:tab]=="updates" and params[:subtab]=="all")
      @news_feed_with_total_pages = ActivitiesFeed.get_all_activities(params[:page])
    end
  end
  
  def get_deals
    #######################################
    # Deals Tab - Load deals from BookingBuddy and other srcs
    #######################################

    @hotel_feed = Array.new
    
    rec_cities = City.find([609,610,672,1530])
    @san_francisco = rec_cities[0]
    @new_york = rec_cities[1]
    @los_angeles = rec_cities[2]
    @las_vegas = rec_cities[3]
    
    remote_ip = request.remote_ip
    onclick_analytics_h = "pageTracker._trackEvent('BookingBuddy', 'click_from_dashboard', 'hotel');"
    onclick_analytics_p = "pageTracker._trackEvent('BookingBuddy', 'click_from_dashboard', 'package');"
    onclick_analytics_f = "pageTracker._trackEvent('BookingBuddy', 'click_from_dashboard', 'flight');"
    
    current_user.cities.each_with_index do |c,i|
      ##### Deals #######
      h_request_url = "http://deals.bookingbuddy.com/delivery/deliver?ip_address=#{remote_ip}&publisher_id=92&no_ads=5&placement=dashboard&multiple=1&auto_backfill=0&lat=#{c.latitude}&lon=#{c.longitude}&radius=30"
      h_request_url = h_request_url + "&test=1" if "production" != RAILS_ENV
      hotel_doc = WebApp.consume_xml_from_url(h_request_url)
    
      @hotel_feed[i] = ""
      (hotel_doc/:Deal).each_with_index do |deal,index|
        if index%2 == 0
          @hotel_feed[i] = @hotel_feed[i] + "<li class=\"even\" onclick=\"window.open('#{deal.at('URL').innerHTML}');#{onclick_analytics_h}return false;\">"
        else
          @hotel_feed[i] = @hotel_feed[i] + "<li onclick=\"window.open('#{deal.at('URL').innerHTML}');#{onclick_analytics_h}return false;\">"
        end
        @hotel_feed[i] = @hotel_feed[i] + "<span class=\"price\"><a href=\"#\">#{deal.at('Price').innerHTML}</a></span>"
        @hotel_feed[i] = @hotel_feed[i] + "<a href=\"#\">#{deal.at('Title').innerHTML}</a>"
        @hotel_feed[i] = @hotel_feed[i] + "<span class=\"advertiser\">#{deal.at('AdvertiserName').innerHTML}</span>"
        @hotel_feed[i] = @hotel_feed[i] + "</li>"
      end
    end 
    
    respond_to do |format|
      format.js { render :partial => "/users/dashboard_partials/travel_deals" }
    end
  end
  
  def more_news_feed
    if params[:profile]
      u = User.find_by_username(params[:profile])
      
      ####################
      # Load Single User News Feed
      ####################
      @news_feed_with_total_pages = ActivitiesFeed.get_activities([u], params[:page], 30)
      
    elsif params[:subtab]=="all"
      ####################
      # Load All News Feed
      ####################
      @news_feed_with_total_pages = ActivitiesFeed.get_all_activities(params[:page])
      
    else # params[:updates]
      ####################################
      # Load Friends & Requested Friends
      ####################################
      if !fragment_exist?("#{current_user.username}-friends", :time_to_live => 1.week)
        @friends = User.load_all_confirmed_friends(current_user.id)
        write_fragment("#{current_user.username}-friends", @friends)
      else
        @friends = read_fragment("#{current_user.username}-friends")
      end
    
      #####################
      # Load Friends News Feed
      #####################
      @news_feed_with_total_pages = ActivitiesFeed.get_activities(@friends, params[:page], 30)
    end
  end

  def new
    if logged_in?
      redirect_to dashboard_path
    else
      @title = "Duffel - New User"
      @user = User.new(:invitation_token => params[:invitation_token])
      @user.email = @user.beta_invitation.recipient_email if @user.beta_invitation 
      render :layout => 'simple_without_search'
    end
  end

  def create
    cookies.delete :auth_token
    cookies.delete :new_visitor_trip # deletes temp trip
    # protects against session fixation attacks, wreaks havoc with request forgery protection.
    # uncomment at your own risk
    # reset_session
    
    if params[:iphone] == WebApp::IPHONE_API_TOKEN
      @user = User.new(:username => params[:username], :password => params[:password], :email => params[:email])
      @user.source = "iphone"
    elsif !params[:iphone]
      @user = User.new(params[:user])
      if params[:from]
        @user.source = params[:from].to_s
      else
        @user.source = "web"
      end
    end
    
    @user.username.downcase! # downcase all username
    @user.category = 1 # normal user
    @user.email_updates = 29 # send newsletter
    
    respond_to do |format|
        
      if (!params[:recaptcha_challenge_field] and !params[:recaptcha_response_field]) or verify_recaptcha(@user)
        if @user.save
          self.current_user = @user
        
          # iPhone verification token
          # TO DO - beef up security here to match the key
          if params[:iphone] == WebApp::IPHONE_API_TOKEN
            # create iphone_api_key
            key = ApiKey.check_api_key(current_user, "iphone")
          end
      
          # Do some stuff when new user is created
          Friendship.add_duffel_professor(@user)
          Postoffice.deliver_welcome(@user)
        
          if params[:new_visitor_trip]
            # Save new_visitor_trip as new user's trip
            t = Trip.find_by_permalink(params[:new_visitor_trip])
            t.active = 1 # activate trip so signed up user can see it
            t.save!
            
            Invitation.invite_self(@user, t)
          else
            # Create a new duffel as "research duffel"
            Trip.create_duffel_for_new_user({ :title => "#{@user.username}'s first duffel", :start_date => nil,
                                            :end_date => nil, :is_public => 1, :destination => "San Francisco, CA, United States" }, current_user)
          end
      
          # Add a city to follow its travel deals
          @user.cities << City.find_by_id(609)
      
          # Do some more stuff if user is invited by a friend or to a duffel
          if !@user.beta_invitation.nil?
            # Request friendship
            Friendship.request(@user.beta_invitation.sender, @user)
        
            # Add to duffel
            if !@user.beta_invitation.trip_id.nil?
              trip = Trip.find_by_id(@user.beta_invitation.trip_id)
              Invitation.invite(@user, trip)
              expire_fragment "#{trip.id}-users"
            end
          end
        
          flash[:notice] = "Thanks for signing up.  We sent you an email confirmation."
          if params[:from]
            format.html { redirect_back_or_default('researches/new') }
          else
            format.xml { render :xml => { :status => :login_successful, :username => current_user.username, :iphone_auth_token => key } }
            format.json { render :json => { :status => :login_successful, :username => current_user.username, :iphone_auth_token => key } }
            format.html { redirect_to(steptwo_path) }
          end
        else
          if params[:from]
            format.html { redirect_to bookmarklet_login_path(:redirect => params[:redirect]) }
          else
            format.html {render :action => 'new', :layout => 'simple_without_search'}
          end
        end
      else
        format.html { render :action => 'new', :layout => 'simple_without_search' }
      end
    end

  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
      format.xml { render :xml => @user.errors,  :status => :unprocessable_entity } 
      format.json { render :json => @user.errors,  :status => :unprocessable_entity } 
    end
  end
  
  def edit
    @title = "Duffel - Edit Account"
    @user = current_user
    
    respond_to do |format|
      format.html 
      format.xml { render :xml => @user } 
      format.json { render :json => @user } 
    end
  end
  
  def save
    return unless request.post?
    email_update = 0
    @user = current_user
    
    # Figure out email numeric value to store in single column email_update
    email_update = params[:email_newsletter] == "checked" ? email_update + User::EMAIL_NEWSLETTER["value"] : email_update
    email_update = params[:email_favorite] == "checked" ? email_update + User::EMAIL_FAVORITE["value"] : email_update
    email_update = params[:email_comment] == "checked" ? email_update + User::EMAIL_COMMENT["value"] : email_update
    email_update = params[:email_trip_reminder] == "checked" ? email_update + User::EMAIL_TRIP_REMINDER["value"] : email_update
    params[:user][:email_updates] = email_update
    
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Thanks, we updated your account information.'
      redirect_to(edit_user_path)
    else
      render :action => 'edit'
    end
  end

  def password
    @title = "Duffel - Change Password"
  end
    
  def password_save
    return unless request.post?
    
    # if password is not set right now
    if current_user.crypted_password.nil? or current_user.crypted_password.empty?
      if params[:password] != params[:retype_password]
        flash[:error] = "Your passwords do not match. A typo perhaps?" 
        redirect_to(password_path) and return
      else
        current_user.password = params[:password]
        
        if current_user.save(false)
          flash[:notice] = "Thanks, we updated your password." 
          redirect_to(password_path) and return
        else
          flash[:error] = "Cannot save password.  Is your password at least #{User::PASSWORD_MIN_LENGTH} characters long?" 
          redirect_to(password_path) and return
        end
      end
    end
    
    # if password has already been set
    if User.authenticate(current_user.username, params[:current_password])
      current_user.password = params[:password]

      if current_user.save
        flash[:notice] = "Thanks, we updated your password." 
        redirect_to(password_path)
      else
        flash[:error] = "Cannot change password.  Is your password at least #{User::PASSWORD_MIN_LENGTH} characters long?" 
        redirect_to(password_path)
      end
    else
      flash[:error] = "Oops, your password is incorrect." 
      redirect_to(password_path)
    end
  end
  
  def steptwo
    @title = "Install Duffel \"Add to Duffel\" Bookmarker"
    @user = current_user
    render :layout => 'simple_without_search'
  end
  
  def search
    @title = "Duffel - Search Duffelers"
    return if params[:q].nil?
    
    unless params[:q].empty?
      username_regex = /\Afriend:/
      if username_regex.match(params[:q])
        friend_username = params[:q].sub(username_regex, "")
        @friend = User.find_by_username(friend_username)
        @duffelers = User.search_friends(@friend, params[:page])
      else
        @duffelers = User.search(params[:q], params[:page])
      end
      
      respond_to do |format|
        format.html # search.html.erb
        format.js do
          render :update do |page|
            page.replace_html 'search_result', :partial => '/users/search_result'
          end
        end
      end
    else # if params[:q].empty?
      flash[:error] = "Oops, your search query is invalid."
      redirect_to :controller => 'users', :action => 'search'
    end # unless params[:q].empty?
    
  end

  def forgot_password
    if logged_in?
      redirect_to profile_url(:username => current_user.username)
      return
    else
      @title = "Duffel - Forgot Password?"
    end
    
    if request.post?
      @email_field = params[:password][:email]
      @email_field.strip!
      if @email_field =~ /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
        if user = User.find(:first, :conditions => [ "email = ?", @email_field ])
          
          if user.category == 0
            flash[:error] = "This user has been disabled due to abuse.  Please contact us for details."
            redirect_to :action => 'forgot_password'
            return
          end
          
          # reset password
          tmp_password = Digest::SHA1.hexdigest( "#{user.email}#{Time.now.to_s.split(//).sort_by {rand}.join}" )
          new_password = tmp_password.slice!(5..15)
          user.password = new_password
          user.save(false)
          
          # send password
          Postoffice.deliver_reset_password(user, new_password)
          
          flash[:notice] = "Thanks, instructions for resetting your password is on its way."
          redirect_to login_path
          return
        else # can't find email in database
          # ignore email address
          logger.error("ERROR: Someone entered non-existing email in forgot_password!")
          flash[:error] = "Email does not exist.  Why don't you sign up for an account?"
          redirect_to signup_path
          return
        end
      else
        flash[:error] = "Oops, looks like your entered an invalid email address."
        redirect_to :action => :forgot_password
      end
      
    end
    render :layout => 'simple_without_search'
  end
  
  def destroy
    if request.delete?
      @user = current_user
    
      # destroy session
      self.current_user.forget_me if @current_user.is_a? User
      cookies.delete :auth_token
      session[:user] = nil
      @current_user = false
      reset_session
    
      # destroy user
      @user.destroy 
    
      flash[:notice] = "Goodbye for now. Let us know if you change your mind!"
    end
  end
  
  # Hides trip planning dashboard tour
  def hide_tour
    current_user.hide_tour_at = Time.now
    current_user.save(false)
  end

end
