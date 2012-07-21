class FeaturedDuffelsController < ApplicationController
  layout "simple", :except => :index
  
  before_filter :protect_admin_page, :only => [:new, :edit]
  after_filter :clear_featured_cache, :only => [:create, :update, :destroy]
  
  # GET /featured_duffels
  # GET /featured_duffels.xml
  def index
    @trip_comments_size = Hash.new
    @counts = Hash.new
    trips = []
    @users = Hash.new
    @ideas_to_map = []
    
    @title = "Featured Members and Trips - Duffel Visual Trip Planner - Organize Your Travel Itinerary"
    @sub_title = "Featured Members"
    @featured_duffels = FeaturedDuffel.find_per_page(params[:page], FeaturedDuffel::FEATURED_DUFFELS_PER_PAGE)
    
    # clears cache after 1 day
    fragment_exist?("featured-all-stars-members", :time_to_live => 1.day)
                                            
    @featured_duffels.each_with_index do |d,i|
      # store all the trips
      trips << d.trip if !d.trip.nil?
      
      ###################################
      # Load duffel comments count
      ###################################
      if !d.trip.nil? and !fragment_exist?("#{d.trip.id}-comments-size", :time_to_live => 1.day)
        @trip_comments_size["#{d.trip.id}-comments-size"] = d.trip.comments.size.to_s 
        write_fragment("#{d.trip.id}-comments-size", d.trip.comments.size.to_s)
      else
        @trip_comments_size["#{d.trip.id}-comments-size"] = read_fragment("#{d.trip.id}-comments-size")
      end
      
      #################
      # Load ideas for each trip
      #################
      if !d.trip.nil? and !fragment_exist?("#{d.trip.id}-mappable-ideas")
        @ideas_to_map[i] = d.trip.mappable_ideas
        write_fragment("#{d.trip.id}-mappable-ideas", @ideas_to_map[i])
      else
        @ideas_to_map[i] = read_fragment("#{d.trip.id}-mappable-ideas")
      end
    end
    
    # Get trip ids for getting all the users
    t = trips.collect { |x| x.id } 
    @users_by_trip_id = User.find_users_by_trip_ids(t)      
                                      
    @all_trips_favorite_count = Favorite.count_favorites(trips)
    
    ###################################
    # Load featured page stats
    ###################################
    if !fragment_exist?("featured-counts", :time_to_live => 1.day)
      @counts["duffels"] = FeaturedDuffel.count_total_duffels
      @counts["users"] = FeaturedDuffel.count_total_users
      @counts["cities"] = FeaturedDuffel.count_total_cities
      write_fragment("featured-counts", @counts)
    else
      @counts = read_fragment("featured-counts")
    end
    
    ###################################
    # Load cities list and their count
    ###################################
    if !fragment_exist?("featured-cities", :time_to_live => 1.day)
      @cities = FeaturedDuffel.cities
      write_fragment("featured-cities", @cities)
    else
      @cities = read_fragment("featured-cities")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js do
        render :update do |page|
          page.redirect_to("/featured?page=#{params[:page]}")
        end
      end
      format.xml  { render :xml => @featured_duffels }
    end
  end

  # GET /featured_duffels/1
  # GET /featured_duffels/1.xml
  def show
    @trip_comments_size = Hash.new
    @featured_duffel = FeaturedDuffel.find_by_permalink(params[:id])
    
    ###################################
    # Load duffel comments count
    ###################################
    if !fragment_exist?("#{@featured_duffel.trip.id}-comments-size", :time_to_live => 12.hours)
      @trip_comments_size["#{@featured_duffel.trip.id}-comments-size"] = @featured_duffel.trip.comments.size.to_s
      write_fragment("#{@featured_duffel.trip.id}-comments-size", @featured_duffel.trip.comments.size.to_s)
    else
      @trip_comments_size["#{@featured_duffel.trip.id}-comments-size"] = read_fragment("#{@featured_duffel.trip.id}-comments-size")
    end
    
    @all_trips_favorite_count = Favorite.count_favorites([@featured_duffel.trip])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @featured_duffel }
    end
  end

  # GET /featured_duffels/new
  # GET /featured_duffels/new.xml
  def new
    @featured_duffel = FeaturedDuffel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @featured_duffel }
    end
  end

  # GET /featured_duffels/1/edit
  def edit
    @featured_duffel = FeaturedDuffel.find_by_permalink(params[:id])
  end

  # POST /featured_duffels
  # POST /featured_duffels.xml
  def create
    @featured_duffel = FeaturedDuffel.new(params[:featured_duffel])
    
    cities = City.find_id_by_city_country(params[:featured_duffel][:city_country])
    trip = Trip.find_by_permalink(params[:permalink])
    user = User.find_by_username(params[:username])
    
    @featured_duffel.city_id = cities[0].id
    @featured_duffel.user_id = user.id
    @featured_duffel.trip_id = trip.id

    respond_to do |format|
      if @featured_duffel.save
        flash[:notice] = 'Featured Duffel was successfully created. Email sent.'
        
        # Send email notification
        Postoffice.deliver_featured_on_all_stars(:user => user, :trip => trip)
        
        format.html { redirect_to(@featured_duffel) }
        format.xml  { render :xml => @featured_duffel, :status => :created, :location => @featured_duffel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @featured_duffel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /featured_duffels/1
  # PUT /featured_duffels/1.xml
  def update
    @featured_duffel = FeaturedDuffel.find_by_permalink(params[:id])
    
    cities = City.find_id_by_city_country(params[:featured_duffel][:city_country])
    trip = Trip.find_by_permalink(params[:permalink])
    user = User.find_by_username(params[:username])
    
    @featured_duffel.city_id = cities[0].id
    @featured_duffel.user_id = user.id
    @featured_duffel.trip_id = trip.id

    respond_to do |format|
      if @featured_duffel.update_attributes(params[:featured_duffel])
        flash[:notice] = 'Featured Duffel was successfully updated.'
        format.html { redirect_to(@featured_duffel) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @featured_duffel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /featured_duffels/1
  # DELETE /featured_duffels/1.xml
  def destroy
    @featured_duffel = FeaturedDuffel.find_by_permalink(params[:id])
    @featured_duffel.destroy

    respond_to do |format|
      format.html { redirect_to(featured_duffels_url) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_featured_duffel_city_country
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if params[:featured_duffel].nil?
    
    @cities = City.find_by_sql(["SELECT id, city_country FROM cities WHERE (LOWER(city_country) LIKE ?) ORDER BY rank LIMIT 5", params[:featured_duffel][:city_country].downcase+"%"])
  
    render :partial => 'trips/cities'
  end
  
  private
  
  def clear_featured_cache
    expire_fragment "featured-counts"
    expire_fragment "featured-cities"
  end
end
