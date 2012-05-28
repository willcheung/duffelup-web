module UsersHelper
  def collaborator_thumbnail(user, size=25)
    return if user.nil?
    
    home_city = (user.home_city.nil? or user.home_city.blank?) ? "" : (" - " + user.home_city)
    
    if user.avatar.exists?
      "<img rel=\"tooltip\" alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"" + user.avatar.url(:thumb) + "\" width=\"" + size.to_s + "\" height=\"" + size.to_s + "\" />"
    elsif !user.avatar_file_name.nil?
      "<img rel=\"tooltip\" alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"" + user.avatar_file_name + "\" width=\"" + size.to_s + "\" height=\"" + size.to_s + "\" />"
    else
      "<img rel=\"tooltip\" alt=\"" + user.username + home_city + "\" title=\"" + user.username + home_city + "\" src=\"/images/icon-user.png\" width=\"" + size.to_s + "\" height=\"" + size.to_s + "\" />"
    end
  end
  
  def duffel_collaborators(users, max=5)
    return if users.nil?
    
    s = ""
    
    diff = users.size - max
    
    users.each_with_index do |user,i|
      return s if (i == max and users.size == max)
      return s + "&nbsp;and #{diff} more" if (i == max and users.size > max)
      
			if user.respond_to?(:user_type) and user.user_type.to_i == Invitation::USER_TYPE_ADMIN
				s = "<a href=\"#{profile_for(user)}\">#{collaborator_thumbnail(user)}</a> "
			
				if users.size > 1
				  s = s + " &nbsp;+&nbsp; "
				end
			else
				s = s + "<a href=\"#{profile_for(user)}\">#{collaborator_thumbnail(user)}</a> "
			end
			
		end
		
		return s
  end
end