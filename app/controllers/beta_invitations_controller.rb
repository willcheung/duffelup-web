class BetaInvitationsController < ApplicationController
  layout "simple"
  
  before_filter :protect, :only => [ :new, :email, :facebook ]
  
  def new
    @title = "Duffel - Invitation"
    @beta_invitation = BetaInvitation.new
  end
  
  def email
    @title = "Duffel - Invitation"
    @beta_invitation = BetaInvitation.new
 end
  
  def facebook
    @title = "Duffel - Invitation"
    @beta_invitation = BetaInvitation.new
    @fb_login_button_url = "/users/link_user_accounts?redirect=/beta_invitations/facebook"
    
    ########## Handle facebook sign up URLs ##############
    if current_user.facebook_user?
      b = BetaInvitation.find_by_sender_id_and_recipient_email_and_trip_id(current_user.id, "facebook_user", nil)
      
      if b.nil? or b.recipient_email != "facebook_user"
        beta_invitation = BetaInvitation.new(:recipient_email => "facebook_user",
                                             :sender => current_user,
                                             :sent_at => Time.now)
                                             beta_invitation.save(false)
      
      @fb_url = "http://duffelup.com/signup?invitation_token="+"#{beta_invitation.token}"
      else
        @fb_url = "http://duffelup.com/signup?invitation_token="+b.token
      end
      
      @fb_string = "DuffelUp.com is a fun an easy way to collect travel ideas and photos." + 
                   " Create your travel corkboard right now!"
    end
  end
  
  def get_fb_friends
    if fb_session
      begin
        graph = Koala::Facebook::API.new(fb_session.access_token)
        @all_fb_friends = graph.get_connections("me","friends")
      rescue Koala::Facebook::AuthenticationError
        session['fb_uid'] = nil
        session['fb_access_token'] = nil
        if fb_session
          graph = Koala::Facebook::API.new(fb_session.access_token)
          @all_fb_friends = graph.get_connections("me","friends")
        end
      end
    end
    
    # get all the facebook IDs and comma separate them
    f = @all_fb_friends.collect { |i| i["id"] }
    f_ids = f.join(",")
    # Then submit it to db and returns all the existing duffels users on fb
    fb_friends = User.find_fb_users(f_ids)
    @fb_friends = fb_friends.collect { |i| i.fb_user_id }
    
    respond_to do |format|
      if params[:trip]
        format.js { render :partial => "invitation/fb_friends_checkbox_for_trips" }
      else
        format.js { render :partial => "invitation/fb_friends_checkbox" }
      end
    end
  end
  

  def create
    # Handle usernames (already on Duffel)
    unless params[:friend_invitation].nil? or params[:friend_invitation].empty?
      friends = params[:friend_invitation]
      friends.each do |f|
        friend = User.find_by_username(f)
        Friendship.request_and_send_email(current_user, friend, profile_url(current_user.username),
                                          "<a target=\"_blank\" href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => current_user.username, :return_to => profile_url(friend.username)) + "\">Accept</a>")
      end
    end
    
    # Handle email addresses
    unless params[:beta_invitation].nil? or params[:beta_invitation][:recipient_email].nil? or params[:beta_invitation][:recipient_email].empty?
      @beta_invitation = BetaInvitation.new(params[:beta_invitation])
      @beta_invitation.sender = current_user if logged_in?
      if @beta_invitation.save
        Postoffice.deliver_new_user_invitation(current_user, @beta_invitation, params[:message], @beta_invitation.token)
      else
        render :action => 'new'
      end
    end
    
    if params[:invitation].nil?
      flash[:notice] = "Nobody was invited."
      redirect_to(dashboard_path)
      return
    end
    
    # Handle facebook_uid (already on Duffel)
    unless params[:invitation][:not_friend].nil? or params[:invitation][:not_friend].empty?
      friends = params[:invitation][:not_friend]
      friends.each do |f|
        friend = User.find_by_fb_user_id(f)
        Friendship.request_and_send_email(current_user, friend, profile_url(current_user.username),
                                          "<a target=\"_blank\" href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => current_user.username, :return_to => profile_url(friend.username)) + "\">Accept</a>")
      end
    end
    
    # Handle facebook invitations
    unless params[:invitation][:not_user].nil? or params[:invitation][:not_user].empty?
      fb_friends = params[:invitation][:not_user]
    end
    
    flash[:notice] = "Thanks, your invitation is on its way."
    redirect_to(dashboard_path)
  end
  
end