module ProfileHelper
  def display_thumbnail_title(username, full_name, city)
    out = (full_name.nil? or full_name.empty?) ?  username : full_name
    unless city.nil? or city.empty?
      out = out + " - " + city.gsub(", United States", "")
    end
    return out
  end
  
  def display_thumbnail(user=nil, options={ :width => "" })
    unless user.nil?
      if user.avatar.exists? 
        image_tag(user.avatar.url(:thumb), :width => options[:width], :title => display_thumbnail_title(user.username, user.full_name, user.home_city), :class => "image")
      elsif !user.avatar_file_name.nil? 
        image_tag(user.avatar_file_name, :width => options[:width], :title => display_thumbnail_title(user.username, user.full_name, user.home_city), :class => "image")
      else
        image_tag("../images/icon-user.png", :width => options[:width], :title => display_thumbnail_title(user.username, user.full_name, user.home_city), :class => "image")
      end
    else
      image_tag("../images/icon-user.png", :width => options[:width], :class => "image")
    end
  end
end
