class AdminController < ApplicationController
  before_filter :protect_admin_page
  layout "simple"
  
  def index
    time_now = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    thirty_days_ago = (Time.now - 30.days).strftime("%Y-%m-%d_%H-%M-%S")
    sixty_days_ago = (Time.now - 60.days).strftime("%Y-%m-%d_%H-%M-%S")
    
    @user_count = User.count_by_sql("select count(*) from users")
    @user_count_30 = User.count_by_sql("select count(*) from users where last_login_at >= '"+thirty_days_ago+"'")
    @user_count_60 = User.count_by_sql("select count(*) from users where last_login_at >= '"+sixty_days_ago+"'")
  
    @user_signup_channels = User.find_by_sql("select source,count(source) as count_src from users group by source;")
  
    @fb_user_count = User.count_by_sql("select count(*) from users where fb_user_id is not null")
    
    @email_invitation_sent = User.count_by_sql("select count(*) from beta_invitations where recipient_email != 'facebook_user'")
    @fb_invitation_sent = User.count_by_sql("select count(*) from beta_invitations where recipient_email='facebook_user'")
  
    @email_invitation_signup = User.count_by_sql("select count(*) from users where beta_invitation_id in (select id from beta_invitations where recipient_email!='facebook_user')")
    @fb_invitation_signup = User.count_by_sql("select count(*) from users where beta_invitation_id in (select id from beta_invitations where recipient_email='facebook_user')")
  
    @has_one_or_more_duffels = User.count_by_sql("select count(distinct(user_id)) from invitations")
    @has_two_or_more_duffels = User.count_by_sql("select count(*) from (select count(user_id) as num_of_duffels, user_id from invitations group by user_id having num_of_duffels > 1) as temp")
    
    @duffel_count_private = Trip.count_by_sql("select count(*) from trips where is_public=0;")
    @duffel_count_public = Trip.count_by_sql("select count(*) from trips where is_public=1;")
  
    @four_or_more_days_duffels = Trip.count_by_sql("select count(*) from trips where duration > 3")
    @one_to_three_days_duffels = Trip.count_by_sql("select count(*) from trips where duration <= 3 and duration > 0")
    @no_date_duffels = Trip.count_by_sql("select count(*) from trips where duration = 0")
    
    @has_more_than_one_collabs = Trip.count_by_sql("select count(*) from (select count(trip_id) as num_of_duffels, trip_id from invitations group by trip_id having num_of_duffels > 1) as temp")
    
    @activities_count = Event.count_by_sql("select count(*) from events where eventable_type='Activity'")
    @fooddrink_count = Event.count_by_sql("select count(*) from events where eventable_type='Foodanddrink'")
    @lodging_count = Event.count_by_sql("select count(*) from events where eventable_type='Hotel'")
    @transportation_count = Event.count_by_sql("select count(*) from events where eventable_type='Transportation'")
    @notes_count = Event.count_by_sql("select count(*) from events where eventable_type='Notes'")
    @total_event_count = @activities_count + @fooddrink_count + @lodging_count + @transportation_count + @notes_count
    
    @login_once_user_count = User.count_by_sql("select count(*) from users where last_login_at is null")
    
    @new_user_count_last_month = User.count_by_sql("select count(*) from users where created_at >= '"+thirty_days_ago+"'")
    @new_user_count_two_months_ago = User.count_by_sql("select count(*) from users where created_at <= '"+thirty_days_ago+"' and created_at >='"+sixty_days_ago+"'")
  
  end
end
