module TripsHelper
  # Displays date in short format.  Ex: June 5 - July 16, 2008
  def display_trip_dates(start_date, end_date)
    return if end_date.nil? or start_date.nil?
    # ex: June 5-16, 2008
    if start_date.month == end_date.month and start_date.year == end_date.year
      start_date.strftime("%B %e") + "-" + end_date.strftime("%e, %Y")
    # ex: June 5-July 16, 2008
    elsif start_date.month != end_date.month and start_date.year == end_date.year
      start_date.strftime("%B %e") + "-" + end_date.strftime("%B %e, %Y")
    else
      start_date.strftime("%B %e, %Y") + "-" + end_date.strftime("%B %e, %Y")
    end
  end
  
  def display_num_favorites(trip)
    if (Favorite.find_by_trip_id(trip))
      @all_favorites = Favorite.find_all_by_trip_id(trip)
      return @all_favorites.size
    end
  end
  
  def idea_type_for_printing(event)
    case event.class.to_s
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
  
  def expand_all_javascript
    details = expand = collapse = ""
    
    (@trip.duration+1).times do |day|
      for e in @itinerary[day+1]
        details = details + "'" + e.id.to_s + "_details',"
        expand = expand + "'" + e.id.to_s + "_expand',"
        collapse = collapse + "'" + e.id.to_s + "_collapse',"
      end
    end
    
    if details.empty? or expand.empty? or collapse.empty?
      return
    else
      return ("expandAll([" + details.chop + "]);collapseAll([" + expand.chop + "]);expandAll([" + collapse.chop + "]);")
    end
  end
  
  def collapse_all_javascript
    details = expand = collapse = ""
    
    (@trip.duration+1).times do |day|
      for e in @itinerary[day+1]
        details = details + "'" + e.id.to_s + "_details',"
        expand = expand + "'" + e.id.to_s + "_expand',"
        collapse = collapse + "'" + e.id.to_s + "_collapse',"
      end
    end
    
    if details.empty? or expand.empty? or collapse.empty?
      return
    else
      return ("collapseAll([" + details.chop + "]);expandAll([" + expand.chop + "]);collapseAll([" + collapse.chop + "]);")
    end
  end
  
  def duffel_thumbnail_style(trip)
    if !trip.photo.size.nil? and trip.photo.size != ""
      "background-image:url('#{trip.photo.url(:thumb)}')"
    elsif !trip.photo_file_name.nil?
      "background-image:url('#{trip.photo_file_name}')"
    else
      ""
    end
  end
  
  def duffel_thumbnail_url(trip)
    if !trip.photo.size.nil? and trip.photo.size != ""
      trip.photo.url(:small) # TO DO - change to :thumb later
    elsif !trip.photo_file_name.nil?
      trip.photo_file_name.gsub("_s", "")
    else
      "http://duffelup.com/images/icon-duffel.gif"
    end
  end
  
  def trip_destination_in_trip_header(city)
    string = ""

    city.each do |c|
      if c.nil? or c.blank?
        # do nothing
      else
        if c.city == ""
          string = string + "<span class=\"destination\"><a title=\"Find more inspiration in #{c.city_country}\" alt=\"Find more inspiration in #{c.city_country}\" href=\"/country/#{c.country_code}\">"+c.city_country.gsub(", United States", "")+"</a></span>"
        elsif c.country_code == "US" or c.country_code == "CA"
          string = string + "<span class=\"destination\"><a title=\"Find more inspiration in #{c.city}\" alt=\"Find more inspiration in #{c.city}\" href=\"/#{c.country_code}/#{c.region}/#{city_name_to_url(c.city)}\">"+c.city_country.gsub(", United States", "")+"</a></span>"
        else
          string = string + "<span class=\"destination\"><a title=\"Find more inspiration in #{c.city}\" alt=\"Find more inspiration in #{c.city}\" href=\"/#{c.country_code}/#{city_name_to_url(c.city)}\">"+c.city_country+"</a></span>"
        end
      end
    end

    return string
  end
  
  def build_static_map_url(event, size="320x120")
    s = "http://maps.google.com/maps/api/staticmap?center=#{event.lat.to_s[0..7]},#{event.lng.to_s[0..7]}"
    
    if event.eventable_type.to_s == "Foodanddrink"
      s = s + "&markers=size:small|color:blue"
    elsif event.eventable_type.to_s == "Activity"
      s = s + "&markers=size:small|color:green"
    elsif event.eventable_type.to_s == "Hotel"
      s = s + "&markers=size:small|color:gray"
    elsif event.eventable_type.to_s == "CheckIn"
      s = s + "&markers=size:small|color:purple"
    else
      s = s + "&markers=size:small|color:gray"
    end
    
    s = s + "|#{event.lat.to_s[0..7]},#{event.lng.to_s[0..7]}&zoom=14&size="+size+"&maptype=road&sensor=false&style=feature:landscape%7Celement:geometry%7Chue:0xf0eade%7csaturation:8&style=feature:road|element:geometry|hue:0xf0d59f|saturation:34|lightness:30"
    
    return s
  end
  
end
