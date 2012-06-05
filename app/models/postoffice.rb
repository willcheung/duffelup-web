class Postoffice < ActionMailer::Base
  helper :application

  def welcome(user)
     from "postoffice@duffelup.com (DuffelUp.com)"
     headers "Reply-to" => "postoffice@duffelup.com"
     recipients user.email
     subject "Welcome to DuffelUp.com"
     body :username => user.username
     sent_on Time.now
     content_type "text/html"
  end
  
  def feedback(feedback_body, username, email)
    from "postoffice@duffelup.com"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients  "feedback@duffelup.com"
    subject "Feedback from " + username + "(" + email + ")"
    body feedback_body
    sent_on Time.now
    content_type "text/html"   
  end
  
  def new_user_invitation(inviter, invitation, personal_message, token)
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients invitation.recipient_email
    name = (inviter.full_name.nil? or inviter.full_name.empty?) ? inviter.username : inviter.full_name
    subject name + " invited you to Duffel"
    body :inviter => inviter, :personal_message => personal_message, :token => token
    sent_on Time.now
    content_type "text/html"
    invitation.update_attribute(:sent_at, Time.now)
  end
  
  def reset_password(user, password)
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients user.email
    subject "Duffel - Reset Password"
    body :user => user, :password => password
    sent_on Time.now
    content_type "text/html"
  end
  
  def friend_request(mail)
    return if mail[:friend].email.nil? or mail[:friend].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:friend].email
    name = (mail[:user].full_name.nil? or mail[:user].full_name.empty?) ? mail[:user].username : mail[:user].full_name
    subject "You have a friend request from " + name + " on DuffelUp.com"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def friendship_approval(mail)
    return if mail[:friend].email.nil? or mail[:friend].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:friend].email
    name = (mail[:user].full_name.nil? or mail[:user].full_name.empty?) ? mail[:user].username : mail[:user].full_name
    subject "You are now friends with " + name + " on DuffelUp.com"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def trip_invitation(mail)
    return if mail[:friend].email.nil? or mail[:friend].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:friend].email
    name = (mail[:inviter].full_name.nil? or mail[:inviter].full_name.empty?) ? mail[:inviter].username : mail[:inviter].full_name
    subject name + " shared a duffel with you"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def new_user_and_trip_invitation(mail)
    return if mail[:friend_email].nil? or mail[:friend_email].empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:friend_email]
    name = (mail[:inviter].full_name.nil? or mail[:inviter].full_name.empty?) ? mail[:inviter].username : mail[:inviter].full_name
    subject name + " shared a trip with you on DuffelUp.com"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def comment_notification(mail)
    return if mail[:trip_creator].email.nil? or mail[:trip_creator].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:trip_creator].email
    name = (mail[:commenter].full_name.nil? or mail[:commenter].full_name.empty?) ? mail[:commenter].username : mail[:commenter].full_name
    subject name + " commented on the duffel #{mail[:trip_title]}"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def add_to_favorite_notification(mail)
    return if mail[:trip_creator].email.nil? or mail[:trip_creator].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:trip_creator].email
    name = (mail[:user].full_name.nil? or mail[:user].full_name.empty?) ? mail[:user].username : mail[:user].full_name
    subject name + " added on your duffel #{mail[:trip].title} as a favorite"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def like_notification(mail)
    return if mail[:event_creator].email.nil? or mail[:event_creator].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:event_creator].email
    name = (mail[:liker].full_name.nil? or mail[:liker].full_name.empty?) ? mail[:liker].username : mail[:liker].full_name
    subject name + " liked your post on DuffelUp.com"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
  
  def share_itinerary_after_trip(mail)
    return if mail[:email].nil? or mail[:email].empty?
    
    d = mail[:trip_dest].gsub(", United States", "").gsub(";", " & ").squeeze(" ")
    url = "http://duffelup.com/trips/"+mail[:trip_perma]
    name = (mail[:full_name].nil? or mail[:full_name].empty?) ? mail[:username] : mail[:full_name]
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:email] 
    subject "Tell us about your trip to #{d}"
    body :name => name, :trip_is_public => mail[:trip_is_public], :destination => d, :trip_url => url, :trip_edit_url => url+"/edit", :trip_title => mail[:trip_title]
    sent_on Time.now
    content_type "text/html"
  end

  def print_itinerary_before_trip(mail)
    return if mail[:email].nil? or mail[:email].empty?
    
    dest = mail[:trip_dest].gsub(", United States", "").gsub(";", " & ").squeeze(" ")
    url = "http://duffelup.com/trips/"+mail[:trip_perma]+"/print_itinerary"
    name = (mail[:full_name].nil? or mail[:full_name].empty?) ? mail[:username] : mail[:full_name]
    
    ###################################
    # Parse trip destination
    ##################################
    split_dest = mail[:trip_dest].split(";")

    split_dest.each do |d|
      d.strip!

      # Find viator event by city, country 
      @viator_ideas = ViatorEvent.find_by_sql(["select v.id,
                                v.product_name,
                                v.product_url,
                                v.price,
                                v.avg_rating,
                                v.city
                              from viator_events v 
                              inner join cities c on c.airport_code = v.iata_code 
                              where c.city_country=? and 
                                v.price < 201 and 
                                v.price > 2 and
                                v.avg_rating > 3
                              order by v.id
                              limit 3", d])
    
      ####################################
      # Find viator destination
      # Doesn't work because d=city,country
      ####################################
      #@viator_destinations = ViatorEvent.find_by_sql(["Select id,destination_name,destination_url from viator_destinations where destination_name like ? limit 2", "%"+d+"%"])
    end
    
    if @viator_ideas.nil? or @viator_ideas.empty?
      body :name => name, :destination => dest, :print_trip_url => url
    else
      body :name => name, :destination => dest, :print_trip_url => url, 
            :viator_idea_url0 => @viator_ideas[0].product_url, 
            :viator_idea_url1 => @viator_ideas[1].product_url, 
            :viator_idea_url2 => @viator_ideas[2].product_url, 
            :viator_idea_name0 => @viator_ideas[0].product_name,
            :viator_idea_name1 => @viator_ideas[1].product_name,
            :viator_idea_name2 => @viator_ideas[2].product_name,
            :viator_idea_price0 => @viator_ideas[0].price,
            :viator_idea_price1 => @viator_ideas[1].price,
            :viator_idea_price2 => @viator_ideas[2].price,
            :viator_idea_rating0 => @viator_ideas[0].avg_rating,
            :viator_idea_rating1 => @viator_ideas[1].avg_rating,
            :viator_idea_rating2 => @viator_ideas[2].avg_rating
    end
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:email]
    subject "Reminder on your upcoming #{mail[:trip_title]} trip"
    sent_on Time.now
    content_type "text/html"
  end
  
  def featured_on_all_stars(mail)
    return if mail[:user].email.nil? or mail[:user].email.empty?
    
    from "postoffice@duffelup.com (DuffelUp.com)"
    headers "Reply-to" => "postoffice@duffelup.com"
    recipients mail[:user].email
    subject "Your trip is being featured on Duffel"
    body mail
    sent_on Time.now
    content_type "text/html"
  end
end
