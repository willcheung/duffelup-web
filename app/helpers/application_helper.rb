# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # JS form focus
  def set_focus(id)
    javascript_tag("Form.focusFirstElement(\"#{id}\");")
  end
  
  # Ajax validation
  def error_message_for(model, field, options = {})
    options[:success_css_class] ||= 'success'
    options[:error_css_class] ||= 'error'
    options[:hint_css_class] ||= 'hint'
    tag_id = "#{model}_#{field}_validator"
        
    js = "<script type='text/javascript'>
    //<![CDATA[
    document.observe('dom:loaded', function() {
    	new Form.Element.EventObserver('#{model}_#{field}', function(element, value)
      	{new Ajax.Request(
    		'/users/validate?field=#{field}&value=' + value,
    		{ method: 'get', 
    			onSuccess: function(transport)
    			{ 
    				element = document.getElementById('#{tag_id}'); 
    				var output = transport.responseText;
    				var css_class = '#{options[:error_css_class]}';
    				if (output.length == 0) {
    					output = '#{options[:success]}'; 
    					css_class = '#{options[:success_css_class]}'
    				}
                element.innerHTML = output; 
                element.setAttribute('class', css_class);
    			}
    		}
    		);}
    		);});
    //]]>
    </script>"
         
    tag = content_tag :span, options[:hint], :id => tag_id, :class => options[:hint_css_class]
    return tag + js
  end
  
  def fast_link(text, link, html_options='')
   %(<a href="#{ActionController::Base.relative_url_root}/#{link}" #{html_options}>#{text}</a>)
  end
  
  # Return the user's profile URL.
  def profile_for(user)
    profile_url(:username => user.username)
  end
  
  # Announcement
  def current_announcements
    if cookies[:hide_time].nil?
      @current_announcements ||= Announcement.current_announcements(nil)
    else
      @current_announcements ||= Announcement.current_announcements(Time.parse(cookies[:hide_time]))
    end
  end
  
  def shorten_trip_destination(dest)
    dest.gsub(", United States", "").gsub(";", " & ").strip
  end
  
  def display_user_name(user)
    return if user.nil?
    
    (user.full_name.nil? or user.full_name.empty?) ? user.username : user.full_name
  end
  
  # If trip permalink == trip permalink saved in new visitor cookie
  def new_visitor_created_trip?
    return true if !cookies[:new_visitor_trip].nil? and (!@trip.nil? and @trip.permalink == cookies[:new_visitor_trip])
    return false
  end
  
  # Parameters:
  # display - link display name
  # website - website url
  # no_website_display - when website url is empty, display this string
  # options - any HTML options
  def website_link(display, website, no_website_display="", options="")
    return no_website_display if website.empty?
    
    if website.include? "http://" or website.include? "https://"
      return "<a href=\"" + website + "\" target=\"_blank\" " + options + ">" + display + "</a>"
    else
      return "<a href=\"http://" + website + "\" target=\"_blank\" " + options + ">" + display + "</a>"
    end
  end
  
  def founding_member?(user)
    user.id.to_i <= 5000 ? true : false
  end
  
  # Converts city to url and back
  def city_name_to_url(city_name)
    u = city_name.downcase.gsub("-", "_")
    u.gsub(" ", "-")
  end
  
  def url_to_city_name(url)
    c = url.gsub("-", " ")
    c.gsub("_", "-")
  end

  # Friendly Timestamp based on:
  #   http://almosteffortless.com/2007/07/29/the-perfect-timestamp/
  #   http://railsforum.com/viewtopic.php?pid=33185#p33185
  #
  # TODO : Update this to support time zones when added to this app, see example links above for possible help with that.
  def time_ago_or_time_stamp(time = nil, options = {})

    # base time is the time we measure against.  It is now by default.
    base_time = options[:base_time] ||= Time.now

    return '–' if time.nil?

    direction = (time.to_i < base_time.to_i) ? "ago" : "from now"
    distance_in_minutes = (((base_time - time).abs)/60).round
    distance_in_seconds = ((base_time - time).abs).round

    case distance_in_minutes
      when 0..1        then time = (distance_in_seconds < 60) ? "#{pluralize(distance_in_seconds, 'second')} #{direction}" : "1 minute #{direction}"
      when 2..59       then time = "#{distance_in_minutes} minutes #{direction}"
      when 60..90      then time = "1 hour #{direction}"
      when 90..1440    then time = "#{(distance_in_minutes.to_f / 60.0).round} hours #{direction}"
      when 1440..2160  then time = "1 day #{direction}" # 1 day to 1.5 days
      when 2160..2880  then time = "#{(distance_in_minutes.to_f / 1440.0).round} days #{direction}" # 1.5 days to 2 days
      else time = time.strftime("%A, %b %d %Y")
    end
    return time_stamp(time) if (options[:show_time] && distance_in_minutes > 2880)
    return time
  end

  def time_stamp(time)
    time.to_datetime.strftime("%A, %b %d %Y, %l:%M%P").squeeze(' ')
  end
  
  def dec2bin(n)
      [n].pack("N").unpack("B32")[0].sub(/^0+(?=\d)/, '')
  end

  def bin2dec(n)
      [("0"*32+n.to_s)[-32..-1]].pack("B32").unpack("N")[0]
  end
  
  def user_is_subscribed(email_updates, email_type)
    if email_type == User::EMAIL_NEWSLETTER
      return (dec2bin(email_updates).reverse[User::EMAIL_NEWSLETTER["bit_position"],1] == "1") ? true : false
    elsif email_type == User::EMAIL_DUFFEL_DESTINATIONS
      return (dec2bin(email_updates).reverse[User::EMAIL_DUFFEL_DESTINATIONS["bit_position"],1] == "1") ? true : false
    elsif email_type == User::EMAIL_FAVORITE
      return (dec2bin(email_updates).reverse[User::EMAIL_FAVORITE["bit_position"],1] == "1") ? true : false
    elsif email_type == User::EMAIL_COMMENT
      return (dec2bin(email_updates).reverse[User::EMAIL_COMMENT["bit_position"],1] == "1") ? true : false
    elsif email_type == User::EMAIL_TRIP_REMINDER
      return (dec2bin(email_updates).reverse[User::EMAIL_TRIP_REMINDER["bit_position"],1] == "1") ? true : false
    else
      return false
    end
      
  end

  def unicode_to_utf8(unicode_string)
   unicode_string.gsub(/\\u\w{4}/) do |s|
     str = s.sub(/\\u/, "").hex.to_s(2)
     if str.length < 8
       CGI.unescape(str.to_i(2).to_s(16).insert(0, "%"))
     else
       arr = str.reverse.scan(/\w{0,6}/).reverse.select{|a| a != ""}.map{|b| b.reverse}
       hex = lambda do |s|
         (arr.first == s ? "1" * arr.length + "0" * (8 - arr.length - s.length) + s : "10" + s).to_i(2).to_s(16).insert(0, "%")
       end
       CGI.unescape(arr.map(&hex).join)
     end
   end
 end
  
end
