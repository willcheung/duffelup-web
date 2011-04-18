class FavoriteController < ApplicationController
  layout "simple"
  
  before_filter :protect
  after_filter :clear_favorites_cache, :only => [:create, :delete]
    
  def create
    load_trip_and_users
    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil?
    
    news_fb = "added #{@trip.title} (#{trip_url(:id => @trip)}) as one of my favorite duffels."
    
    if Favorite.fav(current_user, @trip)
      ################################################################################
      # publish stream on fb (only works if fb user has approved extended permission) - suspended for now
      ################################################################################
      # if current_user.facebook_user? and @trip.is_public
      #   WebApp.post_stream_on_fb(current_user.fb_user_id, 
      #                           trip_url(:id => @trip),
      #                           news_fb,
      #                           "Check it out") 
      # end
      
      ###################################
      # Twitter status update - suspended for now
      ###################################
      # if current_user.twitter_user? and @trip.is_public
      #   s_url = WebApp.shorten_url(trip_url(:id => @trip))
      #   twitter_client.update("Added trip #{@trip.title} #{s_url} as my favorite on @duffelup", {})
      # end
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_FAVORITE, @trip)
      
      ##############
      # email users
      ##############
      notify_users(@users)
      
      flash[:notice] = "Cool. Added to your favorites collection."
    else
      flash[:notice] = "Already in your favorites collection."
    end
    
    if params[:redirect]
      redirect_to params[:redirect]
    else
      redirect_to trip_path(:id => @trip)
    end
  end
  
  def delete
    if request.post?
      load_trip(params[:permalink])
      
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil?
      
      if Favorite.unfavorite(current_user, @trip)
        flash[:notice] = "This duffel is no longer part of your favorites collection."
      else
        flash[:notice] = "Oops. This duffel is not part of your favorites collections."
      end
      
      if params[:redirect]
	      redirect_to params[:redirect]
      else
	      redirect_to trip_path(:id => @trip)
      end
    else
      redirect_to trip_path(:id => @trip)
    end
  end
    
  private
  
  def load_trip(trip_perma) 
    @trip = Trip.find_by_permalink(trip_perma) 
  rescue RuntimeError
    logger.error("ERROR: RuntimeError in Trip Controller - Trying to access invalid trip with id = "+trip_perma)
  end
  
  def load_trip_and_users
    @admins = []

    @trip = Trip.find_by_permalink(params[:permalink])
    if !fragment_exist?("#{@trip.id}-users", :time_to_live => 1.day)
      @users = User.load_trip_users(@trip.id)
      write_fragment("#{@trip.id}-users", @users)
    else
      @users = User.new
      @users = read_fragment("#{@trip.id}-users")
    end

    # Get all admin users
    @users.each do |u|
      if u.user_type == Invitation::USER_TYPE_ADMIN.to_s
        @admins << u
      end
    end
  rescue RuntimeError
    logger.error("ERROR: RuntimeError in Trip Controller - Trying to access invalid trip with id = "+trip_perma.to_s)
  end
  
  def notify_users(trip_creators)
    trip_creators.each do |u|
      unless current_user == u
        if u.category != User::CATEGORY_DISABLED and !u.email.blank? and user_is_subscribed(u.email_updates, User::EMAIL_FAVORITE) 
          Postoffice.deliver_add_to_favorite_notification(:trip_creator => u,
                                                  :user => current_user,
                                                  :trip => @trip,
                                                  :trip_favorite_url => trip_favorite_url(@trip))
        end
      end
    end
  end
  
  def clear_favorites_cache
    return if @trip.nil?
    
    expire_fragment "user-#{current_user.id}-trip-#{@trip.id}-favorites"
    expire_fragment "user-#{current_user.id}-favorites"
  end
end
