require 'base64'

module EventsHelper
  def idea_type_on_itinerary(event)
    case event.eventable_type
    when "Foodanddrink"
      "<span class=\"fooddrink\">&nbsp;</span>"
		when "Transportation"
	    "<span class=\"transport\">&nbsp;</span>"
		when "Activity"
	    "<span class=\"activity\">&nbsp;</span>"
		when "Hotel"
	    "<span class=\"hotel\">&nbsp;</span>"
		when "Notes"
	    "<span class=\"note\">&nbsp;</span>"
		end
  end
  
  def idea_type_on_board(event)
    case event.eventable_type
    when "Foodanddrink"
		    "<span class=\"fooddrink\">Food &amp; Drink</span>"
		when "Transportation"
	    	"<span class=\"transport\">Transport</span>"
		when "Activity"
	    	"<span class=\"activity\">Activity</span>"
		when "Hotel"
	    	"<span class=\"hotel\">Lodging</span>"
		when "Notes"
	    	"<span class=\"note\">Note</span>"
		end
  end
  
  # Displays short note on the board.
  def display_short_note_on_board(event, trip, partner_id=0)
    if event.eventable_type == "Transportation"
      if (event.note.nil? or event.note.empty?)
        "<p>" + fast_link("(Add notes)", "trips/#{trip.permalink}/ideas/#{event.id}/edit", "rel=\"ibox\"") + "</p>"
      else
        simple_format(h(truncate(event.note, :length => Event::TRUNCATE_SHORT_NOTE_ON_BOARD_BY)))
      end
    else
      if event.attribute_present?(:address) and (event.note.nil? or event.note.empty?) and (event.address.nil? or event.address.empty?) and @users.include?(current_user)
  		  "<p>" + fast_link("(Add notes)", "trips/#{trip.permalink}/ideas/#{event.id}/edit", "rel=\"ibox\"") + "</p>"
  	  elsif not (event.note.nil? or event.note.empty?)
  	    if partner_id == 0
  		    simple_format(h(truncate(event.note, :length => Event::TRUNCATE_SHORT_NOTE_ON_BOARD_BY)))
		    elsif partner_id == Idea::PARTNER_ID["viator"]
		      simple_format(h(truncate(event.note, :length => Event::TRUNCATE_VIATOR_SHORT_NOTE_ON_BOARD_BY)))
	      elsif partner_id == Idea::PARTNER_ID["splendia"]
	        simple_format(h(truncate(event.note, :length => Event::TRUNCATE_HOTELS_SHORT_NOTE_ON_BOARD_BY)))
	      end # Can add other partners here
  	  elsif event.attribute_present?(:address) and not (event.address.nil? or event.address.empty?)
  	    simple_format(h(truncate(event.address, :length => Event::TRUNCATE_SHORT_NOTE_ON_BOARD_BY)))
  	  end
	  end
  end
  
  # This is displayed on the tile.
  def display_title_with_link(event, length=nil)
    length = Event::TRUNCATE_TITLE_LENGTH_ON_TILE if length.nil?
    
		if (event.title.nil? or event.title.empty?)
			"(No Title)"
		else
		  title = h(truncate(event.title, :length => length)).gsub(h("&rarr;"), "&rarr;")
		  case event.eventable_type
      when "Foodanddrink"
  		  website = event.website
  		when "Activity"
  		  website = event.website
  	  when "Hotel"
  	    website = event.website
  	  when "Transportation"
  	    return title
  	  when "Notes"
  	    return title
  	  when "CheckIn"
  	    return title
	    end

			website_link(title, website, title)
		end 
	end
	
	def display_price_range(price_range)
	  if price_range == 1
	    "$"
    elsif price_range == 2
      "$$"
    elsif price_range == 3
      "$$$"
    elsif price_range == 4
      "$$$$"
    end
  end
  
  def display_idea_icon(event)
    if event.eventable_type == "Activity"
      return "/images/ico-activity.gif"
    elsif event.eventable_type == "Foodanddrink"
      return "/images/ico-food.gif"
    elsif event.eventable_type == "Hotel"
      return "/images/ico-lodging.gif"
    end
  end
	
	# This is displayed on the itinerary.
	def display_title_without_link(event, length=nil)
	  length = Event::TRUNCATE_TITLE_LENGTH_ON_TILE if length.nil?
	  
	  if (event.title.nil? or event.title.empty?)
			"(No Title)"
		else
		  h(truncate(event.title, :length => length)).gsub(h("&rarr;"), "&rarr;")
	  end
  end
  
  def display_map_bubble(event)
    html = "<b>" + event.title + "</b><br>"
    html += website_link("Website", event.website) + "<br>"
    html += event.address + "<br>" if not event.address.empty?
    html += event.phone if not event.phone.empty?
    return html
  end
	
	# Accepts display name and an object, which can be an Event object or an address string
	def map_link(display, object)
	  if object.class == String
	    address = object
	  else
	    event = object
  		address = event.address
    end

    # replace whitepace with +
	  tmp_addy = address.gsub(/[ \t\r\n\v\f]/, '+')
	  google_maps_href = "http://maps.google.com/maps?q="+tmp_addy
	  return "<a href=\"" + google_maps_href + "\" target=\"_blank\">" + display + "</a>"
  end
  
  # Modified version of simple_format so <p> tags are not displayed.  This used in itinerary details
  # because <p> tag is hidden via CSS.
  def simple_format_without_p(text, html_options={})
    #start_tag = tag('p', html_options, true)
    text = text.to_s.dup
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, '<br /><br />')  # 2+ newline  -> 2 br
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    
    return text
  end
  
  # Hacked so event can display image using Idea model (instead of Event model)
  # Pin uses Idea model because it has acts_as_mappable
  def get_image_url(event, size="thumb")
    if event.photo_file_size.nil?
      return event.photo_file_name || "/images/icon-duffel.png"
    else
      return "http://s3.amazonaws.com/duffelup_event_#{RAILS_ENV}/photos/#{event.id}/#{size}/#{event.photo_file_name}"
    end
  end
  
  
  def build_url_for_copy(display, event_id, trip_permalink)

    if ENV['RAILS_ENV'] == 'production'
      url = "http://duffelup.com/research/new"
    else
      url = "http://localhost:3000/research/new"
    end
    
    url = url + "?local=true" + 
                "&event_code=" + Base64.encode64(event_id.to_s) + 
                "&trip_code=" + Base64.encode64(trip_permalink)
    
    # opens new window
    return "<a title=\"Add to my duffel\" href=\"" + url + "\" onclick=\"PopupCenter(this.href+'&jump=doclosepopup', 'copy', 500, 380);return false;\">" + display + "</a>"
  end
  
  def sortable_tile
    if new_visitor_created_trip? or (!@users.nil? and @users.include?(current_user) and params[:view] != "itinerary" and params[:view] != "map")
      return true
    else
      return false
    end
  end
  
  def display_transportation_datetime(t)
    Time.parse(t).strftime("%m/%d/%y at %I:%M%p") unless t.nil?
  end 
  
  # Hacked so Idea model can check whether it has a photo (instead of using Event model)
  def photo_exists?(event)
    (!event.photo_file_name.nil? && !event.photo_file_name.empty?) || (event.photo_content_type && event.photo_file_size)
  end
    
end
