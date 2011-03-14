module UsersHelper
  def collaborator_thumbnail(user)
    home_city = (user.home_city.nil? or user.home_city.blank?) ? "" : (" - " + user.home_city)
    
    if user.avatar.exists?
      "<img alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"" + user.avatar.url(:thumb) + "\" width=\"25\" height=\"25\" />"
    elsif !user.avatar_file_name.nil?
      "<img alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"" + user.avatar_file_name + "\" width=\"25\" height=\"25\" />"
    else
      "<img alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"/images/icon-user.png\" width=\"25\" height=\"25\" />"
    end
  end
  
  def duffel_collaborators(users, max=5)
    return if users.nil?
    
    s = ""
    
    diff = users.size - max
    
    users.each_with_index do |user,i|
      return s if (i == max and users.size == max)
      return s + "&nbsp;and #{diff} more" if (i == max and users.size > max)
      
			if user.user_type.to_i == Invitation::USER_TYPE_ADMIN
				s = "<a href=\"#{profile_for(user)}\">#{collaborator_thumbnail(user)}</a> "
			
				if users.size > 1
				  s = s + " &nbsp;+&nbsp; "
				end
			elsif user.user_type.to_i == Invitation::USER_TYPE_MEMBER
				s = s + "<a href=\"#{profile_for(user)}\">#{collaborator_thumbnail(user)}</a> "
			end
			
		end
		
		return s
  end
end