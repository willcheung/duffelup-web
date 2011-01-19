# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout "researches"

  def new
    if logged_in?
      redirect_to dashboard_path
    else
      @title = "Login - Duffel Visual Trip Planner"
      render :layout => 'simple_without_search'
    end
  end
  
  def new_session_bookmarklet
    @title = "Add to Duffel"
    @user = User.new
  end

  def create
    if params[:twitter] == "true"
      request_token = oauth_consumer.get_request_token(:oauth_callback => twitter_callback_session_url)
      
      session['rtoken']  = request_token.token
      session['rsecret'] = request_token.secret

      redirect_to request_token.authorize_url and return
    end
    
    self.current_user = User.authenticate(params[:login], params[:password])
    
    respond_to do |format|
      if logged_in?
      
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        
        # iPhone verification token
        # TO DO - beef up security here to match the key
        if params[:iphone] == WebApp::IPHONE_API_TOKEN
          # create iphone_api_key
          key = ApiKey.check_api_key(current_user, "iphone")
        end

        format.html { redirect_back_or_default(dashboard_path, params[:redirect]) }
        format.xml { render :xml => { :status => :login_successful, :username => current_user.username, :iphone_auth_token => key } }
        format.json { render :json => {:status => :login_successful, :username => current_user.username, :iphone_auth_token => key } }
      else
        flash[:error] = "Your username or password is incorrect."
        if params[:from] == "bookmarklet"
          format.html { redirect_to bookmarklet_login_path(:redirect => params[:redirect]) }
        else
          format.html { redirect_to login_path(:redirect => params[:redirect]) }
        end
        format.xml { render :xml => { :status => :error_login_info } }
        format.json { render :json => { :status => :error_login_info } }
      end
    end
  end

  def destroy
    self.current_user.forget_me if @current_user.is_a? User
    cookies.delete :auth_token
    session[:user] = nil
    session[:atoken] = session[:asecret] = nil
    session[:rtoken] = session[:rsecret] = nil
    @current_user = false
    reset_session
    clear_facebook_session(true)
    flash[:notice] = "You've logged out. Catch you later."
  end
  
  # Called when Twitterer logins in
  def twitter_callback
    request_token = OAuth::RequestToken.new(oauth_consumer, session['rtoken'], session['rsecret'])
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    reset_session
    session['atoken'] = access_token.token
    session['asecret'] = access_token.secret
    profile = twitter_client.verify_credentials
    
    twitter_user = User.find_by_twitter_token_and_twitter_secret(access_token.token, access_token.secret)
    
    # If user is logged in and clicked on "Link"
    if logged_in?
      current_user.twitter_secret = oauth_consumer.access_token.secret
      current_user.twitter_token = oauth_consumer.access_token.token
      current_user.save(false)
      
      twitter_client.update("Checking out @duffelup's Visual Trip Planner. http://duffelup.com", {})
      flash[:notice] = "You linked your Twitter account!"
      redirect_to(dashboard_path) and return
    end
    
    # If user is not logged in
    if !twitter_user.nil?
      self.current_user = twitter_user

      redirect_back_or_default(dashboard_path, params[:redirect]) and return
    else # create new user
      self.current_user = User.create_from_twitter_oauth(profile, session['atoken'], session['asecret'])
      
      Friendship.add_duffel_professor(current_user)
      
      # Create a new duffel as "research duffel"
      Trip.create_duffel_for_new_user({ :title => "#{current_user.username}'s first duffel", :start_date => nil,
                                        :end_date => nil, :is_public => 1, :destination => "#{current_user.home_city}" }, current_user)
      
      twitter_client.update("Checking out @duffelup's Visual Trip Planner. http://duffelup.com", {})
      
      redirect_to(steptwo_path) and return
    end

  end
end
