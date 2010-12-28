module FriendshipHelper

  # Return an appropriate friendship status message.
  def profile_friendship_status(user, friend)
    friendship = Friendship.find_by_user_id_and_friend_id(user, friend)
    
    return "<li><a class='button' href=\"" + url_for(:controller => 'friendship', :action => 'create', :id => friend.username, :return_to => request.request_uri) + "\">Add as contact</a></li>" if friendship.nil?
    
    case friendship.status
    when Friendship::REQUESTED
      "<li>#{friend.username} added you as a contact.<p style='margin-top:10px;'><a class='button' href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => friend.username, :return_to => request.request_uri) + "\">Accept</a> " +
             " <a href=\"" + url_for(:controller => 'friendship', :action => 'ignore', :id => friend.username, :return_to => request.request_uri) + "\"><small>&nbsp; or Decline</small></a></li>"
    when Friendship::PENDING
      "<li>Connection pending with #{friend.username}.<p style='margin-top:10px;'><a class='button' href=\"" + url_for(:controller => 'friendship', :action => 'cancel', :id => friend.username, :return_to => request.request_uri) + "\">Cancel?</a></p></li>"
    when Friendship::ACCEPTED
      "<li><a onclick=\"Effect.toggle('removeFriend', 'blind', { duration: 0.3 });\" href=\"#\">#{friend.username} is a friend</a><div id=\"removeFriend\" style=\"display:none;\">" + 
              "<a class=\"button\" href=\"" + url_for(:controller => 'friendship', :action => 'delete', :id => friend.username, :return_to => request.request_uri) + "\">Remove contact?</a></div></li>"
    end
  end
  
  def search_friendship_status(user, friendship) 
    return "This is you!" if user == current_user
    
    friendship.each do |f|
      if user.id == f.friend_id
        case f.status.to_i
        when Friendship::REQUESTED
          return "#{user.username} added you as a contact." + "<br/><a href=\"" + url_for(:controller => 'friendship', :action => 'accept', :id => user.username, :return_to => request.request_uri) + "\">Accept</a> " + "or" +
                 " <a href=\"" + url_for(:controller => 'friendship', :action => 'ignore', :id => user.username, :return_to => request.request_uri) + "\">Decline</a>"
        when Friendship::PENDING
          return "You requested to connect with #{user.username}." + "<br/><a href=\"" + url_for(:controller => 'friendship', :action => 'cancel', :id => user.username, :return_to => request.request_uri) + "\">Cancel</a>"
        when Friendship::ACCEPTED
          return "#{user.username} is a friend." 
        end
      end
    end
    
    return "#{user.username} is not a contact." + "<br/><a href=\"" + url_for(:controller => 'friendship', :action => 'create', :id => user.username, :return_to => request.request_uri) + "\">Add as contact</a>"
  end
  
end