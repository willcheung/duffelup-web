class FriendshipController < ApplicationController
  before_filter :protect, :except => [:setup_friends, :redirect_to_dashboard_or_current_page, :clear_friendship_cache]
  before_filter :setup_friends
  after_filter :clear_friendship_cache, :only => [:accept, :delete]
  
  # TO DOs:
  # Make sure spiders don't follow the links "accept", "ignore", or "cancel".  Put all destructive actions behind a post request or javascript.
    
  def create
    Friendship.request(@user, @friend)
    Postoffice.deliver_friend_request(:user => @user,
                                      :friend => @friend,
                                      :user_url => profile_url(@user.username),
                                      :accept_url => "<a target=\"_blank\" href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => @user.username, :return_to => profile_url(@friend.username)) + "\">Accept</a>") if !@friend.email.blank?
    flash[:notice] = "Thanks, we sent a message to #{@friend.username} to connect."
    redirect_to_dashboard_or_current_page(params[:return_to], @user.username)
  end
  
  def accept
    if @user.requested_friends.include?(@friend)
      Friendship.accept(@user, @friend)
      flash[:notice] = "You are now travel buddies with #{@friend.username}."
      
      Postoffice.deliver_friendship_approval(:user => @user,
                                             :friend => @friend,
                                             :user_url => profile_url(@user.username))
      
      ###################################
      # publish news to activities feed
      ###################################
      ActivitiesFeed.insert_activity(@user, ActivitiesFeed::APPROVE_FRIENDSHIP, nil, fast_link(display_user_name(@friend), "#{@friend.username}"))
      ActivitiesFeed.insert_activity(@friend, ActivitiesFeed::APPROVE_FRIENDSHIP, nil, fast_link(display_user_name(@user), "#{@user.username}"))
    else
      flash[:error] = "No friendship request from #{@friend.username}."
    end
    
    redirect_to_dashboard_or_current_page(params[:return_to], @user.username)
  end
  
  def ignore
    if @user.requested_friends.include?(@friend)
      Friendship.breakup(@user, @friend)
      flash[:notice] = "Uh oh. You declined #{@friend.username}'s request to be travel buddies."
    else
      flash[:error] = "No friendship request from #{@friend.username}."
    end
    redirect_to_dashboard_or_current_page(params[:return_to], @user.username)
  end
  
  def cancel
    if @user.pending_friends.include?(@friend)
      Friendship.breakup(@user, @friend)
      flash[:notice] = "Friendship request cancelled.  Try again later?"
    else
      flash[:error] = "No request for friendship with #{@friend.username}"
    end
    redirect_to_dashboard_or_current_page(params[:return_to], @user.username)
  end
  
  def delete
    if @user.friends.include?(@friend)
      Friendship.breakup(@user, @friend)
      flash[:notice] = "You and #{@friend.username} are no longer travel buddies."
    else
      flash[:error] = "You aren't friends with #{@friend.username}"
    end
    redirect_to_dashboard_or_current_page(params[:return_to], @user.username)
  end

  private 
  
  def setup_friends
    @user = current_user
    @friend = User.find_by_username(params[:id])
  end
  
  def redirect_to_dashboard_or_current_page(current_page, username)
    if current_page.nil? or current_page.empty?
      redirect_to dashboard_path
    else
      redirect_to current_page
    end
  end
  
  def clear_friendship_cache
    expire_fragment "#{@user.username}-friends"
    expire_fragment "#{@friend.username}-friends"
    expire_fragment "#{@user.username}-invitation-friends-checkbox"
    expire_fragment "#{@friend.username}-invitation-friends-checkbox"
  end
end
