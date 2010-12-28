class ProfileController < ApplicationController
  include FriendshipHelper
  layout "main"
  
  before_filter :protect, :except => [:trip_is_public, :auto_complete_for_trip_destination, :show]

  def show 
    @user = (logged_in? and current_user.username == params[:username]) ? current_user : User.find_by_username(params[:username])
    @planned_trips = []
    past_trips = []
    @no_date_trips = []
    @favorite_trips = []
    
    if @user
      @title = display_user_name(@user) + "'s trips on Duffel Visual Trip Planner"
      
      ####################################
      # Load Trips and Comments Count
      ####################################
      
      all_trips = Trip.load_trips_and_comments_count(@user.id)
      
      # fragment cache user's favorites
      if !fragment_exist?("user-#{@user.id}-favorites", :time_to_live => 12.hours)
        fav_trips = Trip.find_favorites(@user.id)
        fav_trips.each do |trip|
          @favorite_trips << trip if trip_is_public(trip, @user)
        end
        write_fragment("user-#{@user.id}-favorites", @favorite_trips)
        @favorites_count = Favorite.count_favorites(@favorite_trips)
      else
        @favorite_trips = read_fragment("user-#{@user.id}-favorites")
        @favorites_count = Favorite.count_favorites(@favorite_trips)
      end
      
      # find all (including favorites) trip admin
      t = all_trips.collect { |x| x.id } 
      t << @favorite_trips.collect { |x| x.id }
      t.flatten!
      @users_by_trip_id = User.find_users_by_trip_ids(t)
      
      # find favorite count for all trips (excluding favorites)
      @all_trips_favorite_count = Favorite.count_favorites(all_trips)
        
      # sort each duffel into three buckets: dateless, present, and past duffels
      all_trips.each do |trip|
        if trip.end_date.nil? or trip.start_date.nil?
          @no_date_trips << trip if trip_is_public(trip, @user)
        elsif trip.end_date < Date.today
          past_trips << trip if trip_is_public(trip, @user)
        else
          @planned_trips << trip if trip_is_public(trip, @user)
        end
      end
      
      # planned_trips will be in DESC order
      @planned_trips.reverse!
      
      # group past trips by year
      @past_trips_by_year = past_trips.group_by {|e| e.start_date.year}
      
      ####################################
      # Load Friends & Requested Friends
      ####################################
      # fragment caching
      if !fragment_exist?("#{@user.username}-friends", :time_to_live => 1.week)
        @friends = User.load_all_confirmed_friends(@user.id)
        write_fragment("#{@user.username}-friends", @friends)
      else
        @friends = read_fragment("#{@user.username}-friends")
      end
      
      if @user == current_user
        @requested_friends = User.load_requested_friends(@user.id)
        ####################################
        # Load News Feed
        ####################################
        @news_feed_with_total_pages = ActivitiesFeed.get_activities(@friends, params[:page], 8)
        @activities = ActivitiesFeed.group_activities(@news_feed_with_total_pages)
      end
      
    else
      logger.error("ERROR: Attempt to access invalid username #{params[:username]}")
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return 
    end
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js
      format.xml  { render :xml => { :favorite => @favorite_trips, :planned => @planned_trips, :no_date => @no_date_trips } }
      format.json { render :json => { :favorite => @favorite_trips, :planned => @planned_trips, :no_date => @no_date_trips } }
    end
  end
  
end
