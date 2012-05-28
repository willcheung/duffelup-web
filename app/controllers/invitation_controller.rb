class InvitationController < ApplicationController
  layout "simple"
  
  before_filter :protect, :except => [:load_trip_and_users, :invite_user_and_send_email, :load_trip]
  before_filter :load_trip, :only => [:create, :invite_user_and_send_email]
  after_filter :clear_trip_users_cache, :only => [:create]
  
  def index # Everyone invited to the trip can invite other people 
    @beta_invitation = BetaInvitation.new
    @title = "Duffel - Invite Friends"
    load_trip_and_users(params[:permalink])
    @fb_login_button_url = "/users/link_user_accounts?redirect=#{trip_invitation_path(:permalink => @trip)}#invitations_left-fb"
    
    # If trip not found or not active, return 404.    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return if @trip.nil? or @trip.active == 0
    
    ########## Handle facebook sign up URLs ##############
    if current_user.facebook_user?
      # find existing invitation
      b = BetaInvitation.find_by_sender_id_and_trip_id_and_recipient_email(current_user.id, @trip.id, "facebook_user")
      
      # if no invitation doesn't exist or if invitation exists but does not have receipient_email, then create one
      if b.nil? or b.recipient_email != "facebook_user"
        beta_invitation = BetaInvitation.new(:recipient_email => "facebook_user",
                                             :sender => current_user,
                                             :sent_at => Time.now,
                                             :trip_id => @trip.id)
    
        beta_invitation.save(false)
        @fb_url = "http://duffelup.com/signup?invitation_token="+"#{beta_invitation.token}"
      else
        @fb_url = "http://duffelup.com/signup?invitation_token="+b.token
      end
    
      @fb_string = "I am sharing my travel corkboard " + 
                    " <b>#{@trip.title}</b> with you on DuffelUp.com, a fun an easy way to collect travel ideas and photos."
    end
    
    if !fragment_exist?("#{current_user.username}-invitation-friends-checkbox", :time_to_live => 2.days)
      @friends = current_user.friends
      write_fragment("#{current_user.username}-invitation-friends-checkbox", @friends)
    else
      @friends = User.new
      @friends = read_fragment("#{current_user.username}-invitation-friends-checkbox")
    end
  end
  
  # Invitation process
  # 1) User enters email address to the text field
  # 2) Check whether email address already exist in Duffel
  # 2.1) If yes, invite user despite friendship exists (as long as there's user_id).  Send trip_invitation email.  END
  # 2.2) If no, proceed to #3.
  # 3) Send a new_user_and_trip_invitation email containing a link to sign-up.  Link may contain the user's email.
  # 4) User clicks on the link and activates the account via sign-up / edit user process.
  # 5) Add user friendship request + setup invitation to trip if necessary.
  
  # Find the trip from URL and users from check_boxes, then call 'invite_users' to add them to the trip
  def create
    if request.post?
      # Email Import: Handle usernames already on Duffel
      unless params[:friend_invitation].nil? or params[:friend_invitation].empty?
        friends = params[:friend_invitation]
        friends_array = [] # for storing User objects
        
        friends.each do |f|
          friend = User.find_by_username(f)
          friends_array << friend
          Friendship.request_and_send_email(current_user, friend, profile_url(current_user.username),
                                            "<a target=\"_blank\" href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => current_user.username, :return_to => profile_url(friend.username)) + "\">Accept</a>")
          invite_user_and_send_email(friend, params[:message])
        end
        
        ###################################
        # publish news to activities feed
        ###################################
        # ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::INVITE_TO_TRIP, @trip, username_list_helper(friends_array))
      end
      
      # Handle emails either from import or manually entered
      unless params[:beta_invitation].nil? or params[:beta_invitation][:recipient_email].nil? or params[:beta_invitation][:recipient_email].empty?
        emails = params[:beta_invitation][:recipient_email]
      else
        emails = Invitation.parse_and_validate_emails(params[:emails])
      end
      
      if params[:invitation].nil? and not emails
        #### no checkbox selected nor emails entered ####
        flash[:error] = 'Invitation not sent.  Did you invite any friends?'
        redirect_to trip_invitation_path(:permalink => params[:permalink])
        return
      else
        #### invite friends from checkbox ####
        unless params[:invitation].nil?
          friends_array = [] # for storing User objects
          
          params[:invitation][:user].each do |u|
            user = User.find_by_username(u)
            friends_array << user
            invite_user_and_send_email(user, params[:message])
          end
          
          ###################################
          # publish news to activities feed
          ###################################
          # ActivitiesFeed.insert_activity(current_user, ActivitiesFeed::INVITE_TO_TRIP, @trip, username_list_helper(friends_array))
        end
        
        #### invite friends from email field ####
        if emails
          emails.each do |e|
            user = User.find_by_email(e)
            #### if user email is found in database ####
            unless user.nil?
              invite_user_and_send_email(user, params[:message])
            else
              beta_invitation = BetaInvitation.new(:recipient_email => e,
                                                   :sender => current_user,
                                                   :sent_at => Time.now,
                                                   :trip_id => @trip.id)
              
              if beta_invitation.save
                #### invite user to trip & send new user email####
                invite_user_and_send_email(nil, params[:message], true, beta_invitation.token, e)
              else
                flash[:error] = "Invitation not sent.  Make sure the email is entered correctly!"
                redirect_to trip_invitation_path(:permalink => params[:permalink])
                return
              end # if beta_invitation.save
            end # unless user.nil?
          end # emails.each do |e|
        end # if emails

        flash[:notice] = "Cool. Invitation is on its way."
        redirect_to trip_path(:id => @trip)
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
  end
  
  private
  

  def invite_user_and_send_email(friend, personal_message, new_user_trip=false, invitation_token=nil, friend_email=nil) 
    friend_email = friend.email if friend_email.nil?
           
    Invitation.invite(friend, @trip) unless friend.nil?
    
    if new_user_trip or friend.nil?
      Postoffice.deliver_new_user_and_trip_invitation(:inviter => current_user,
                                                      :friend_email => friend_email,
                                                      :inviter_url => profile_url(current_user.username),
                                                      :trip => @trip,
                                                      :personal_message => personal_message,
                                                      :token => invitation_token) if !friend_email.blank?
    else
      Postoffice.deliver_trip_invitation(:inviter => current_user,
                                      :friend => friend,
                                      :inviter_url => profile_url(current_user.username),
                                      :friend_url => profile_url(friend.username),
                                      :trip_url => trip_url(:id => @trip),
                                      :trip => @trip,
                                      :personal_message => personal_message) if !friend.email.blank?
    end
  end

  def load_trip 
    @trip = Trip.find_by_permalink(params[:permalink]) 
  end
  
  def load_trip_and_users(trip_perma)
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
    logger.error("ERROR: RuntimeError in Trip Controller - Trying to access invalid trip with id = "+trip_perma)
  end
  
  def clear_trip_users_cache
    expire_fragment "#{@trip.id}-users"
  end
  
end
