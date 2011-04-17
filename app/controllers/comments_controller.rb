class CommentsController < ApplicationController
  before_filter :load_trip_and_users, :only => [ :index, :create ]
  after_filter :clear_comments_size_cache, :only => [:create, :destroy]
  layout "simple"
  
  def index
    # If trip not found or not active, return 404.    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil? or @trip.active == 0
    
    # redirect to 404 if trip is private
    if @trip.is_public == 0
      if !logged_in?
        protect
        return
      else
        unless @users.include?(current_user)
          @trip = nil
          render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
        end
      end
    end
    
    @title = "Comments for " + @trip.title
    @comment = Comment.new
    
    ###################################
    # Load duffel comments count
    ###################################
    if !fragment_exist?("#{@trip.id}-comments-size", :time_to_live => 12.hours)
      @trip_comments_size = @trip.comments.size.to_s
      write_fragment("#{@trip.id}-comments-size", @trip_comments_size)
    else
      @trip_comments_size = read_fragment("#{@trip.id}-comments-size")
    end
  end
  
  def create 
    @comment = Comment.new(params[:comment]) 
    @comment.user = current_user
    @comment.trip = @trip 

    # create news text
    news_fb = "commented on duffel #{@trip.title} to #{@trip.destination.gsub(", United States", "").gsub(";", " & ").squeeze(" ")} (#{trip_url(:id => @trip)+"#comments"}).  \"#{@comment.body}\""
    
    respond_to do |format| 
      if @trip.comments << @comment
        ##############
        # email users
        ##############
        dedupe_list = dedupe_trip_users_and_comment_users(@users, @trip.comments)
        notify_users(dedupe_list, @comment)
        
        ################################################################################
        # publish stream on fb (only works if fb user has approved extended permission) - suspended for now
        ################################################################################
        # if !current_user.fb_user_id.nil? and @trip.is_public == 1
        #   WebApp.post_stream_on_fb(current_user.fb_user_id, 
        #                           trip_url(:id => @trip)+"#comments",
        #                           news_fb,
        #                           "Check it out") 
        # end
        
        ###################################
        # Twitter status update - suspended for now
        ###################################
        # if current_user.twitter_user? and @trip.is_public == 1
        #   s_url = WebApp.shorten_url(trip_url(:id => @trip))
        #   twitter_client.update("I commented on a trip on @duffelup: #{truncate(@comment.body,55)} #{s_url}", {})
        # end
        
        ###################################
        # publish news to activities feed
        ###################################
        ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::ADD_COMMENT, @trip)
        
        format.html { redirect_to trip_comments_url(:permalink => @trip) }
        format.js do 
          render :update do |page|
            page.replace_html "comments_for_trip_#{@trip.id}", :partial => "comments/comment", :collection => @trip.comments
            page.visual_effect(:highlight, "comment_#{@comment.id}")
          end
        end 
      else 
        format.html { redirect_to new_trip_comment_url(@trip) } 
        format.js { render :nothing => true } 
      end 
    end 
  end
  
  def destroy 
    @trip = Trip.find_by_permalink(params[:permalink]) 
    
    @comment = Comment.find(params[:id]) 
    if @comment.authorized?(current_user) 
      @comment.destroy 
    else 
      redirect_to trip_path(@trip.id) 
    end 
  
    respond_to do |format| 
      format.js do # destroy.rjs 
        render :update do |page|
          page.visual_effect(:fade, "comment_#{@comment.id}", :duration => 1)
          page.delay 0.9 do
            page.remove "comment_#{@comment.id}"
          end
        end
      end
    end
  end

  private 
  
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
  end
  
  def notify_users(trip_creators, comment)
    trip_creators.each do |u|
      unless current_user == u
        if u.category != User::CATEGORY_DISABLED and !u.email.blank? #and user_is_subscribed(u.email_updates, User::EMAIL_COMMENT)
          Postoffice.deliver_comment_notification(:trip_creator => u,
                                                  :commenter => current_user,
                                                  :trip_title => @trip.title,
                                                  :trip_comment_url => trip_url(:id => @trip)+"#comments",
                                                  :comment => comment.body)
        end
      end
    end
  end
  
  def dedupe_trip_users_and_comment_users(users, comments)
    final_list = users
    flag = 1
    tmp_user = nil
    
    comments.each do |c|
      tmp_user = c.user
      flag = 1
      
      users.each do |u|
        if c.user.id == u.id
          flag = 0 
          break
        end
      end
      
      if flag == 1
        final_list << tmp_user
        tmp_user = nil
      end
    end

    # Debug
    # final_list.each do |f|
    #   logger.error("FINAL LIST = " + f.username)
    # end
    
    return final_list 
      
  end
  
  def clear_comments_size_cache
    expire_fragment "#{@trip.id}-comments-size"
  end
end
