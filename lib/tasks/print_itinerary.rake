namespace :print_itinerary do
    
  desc "Sends emails to users three days after their trips."
  task :send_emails => :environment do
    include ApplicationHelper
    
    # Number of days after the trip to send email
    num_of_days = 8
    users_trips = User.find_by_sql(["SELECT users.id, users.username, users.email, users.full_name, users.email_updates, trips.id as trip_id, trips.title as trip_title, trips.permalink as trip_perma, trips.is_public as trip_is_public, trips.destination as trip_dest
                                      FROM users 
                                      INNER JOIN invitations ON users.id = invitations.user_id
                                      INNER JOIN trips ON invitations.trip_id = trips.id
                                      WHERE trips.start_date = FROM_DAYS(TO_DAYS(CURRENT_DATE)+?) order by permalink", num_of_days])
                                      
    puts "Time now is " + Time.now.to_s + " and we about to send " + users_trips.size.to_s + " emails to print itinerary."
    puts "--------------- end ------------------"
    
    for u in users_trips
      if user_is_subscribed(u.email_updates, User::EMAIL_TRIP_REMINDER)
        Postoffice.deliver_print_itinerary_before_trip(u)
      end
      
      ###################################
      # publish news to activities feed
      ###################################     
      user = User.new(:full_name => u.full_name, :username => u.username)
      user.id = u.id
      trip = Trip.new(:title => u.trip_title, :destination => u.trip_dest)
      trip.id = u.trip_id
      trip.permalink = u.trip_perma
      trip.is_public = u.trip_is_public
      ActivitiesFeed.insert_activity(user, ActivitiesFeed::DEPART_FOR_TRIP, trip)
    end
                    
    # trips = Trip.find_by_sql("SELECT id, title, permalink, is_public, destination FROM trips where end_date = CURRENT_DATE-3;")
    #         
    #         for t in trips
    #           t_string = 
    #         
    #           puts ("----------" + t.title + "---------")
    #           users = User.load_trip_users(t.id)
    #           for u in users
    #             puts (u.username + " (" + u.email + ")")
    #           end
    #         end
    
    #Postoffice.deliver_share_itinerary_after_trip(u, t)
  end
end