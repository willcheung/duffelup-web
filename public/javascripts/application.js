// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// // Disappearing Flash message
// document.observe("dom:loaded", function() {
//   setTimeout(hideFlashMessages, 4000);
// });

$(document).bind("dom:loaded", function() {
	setTimeout(hideFlashMessages, 4000);
});

function hideFlashMessages() {
  $$('p#notice, p#warning, p#error').each(function(e) { 
    if (e) Effect.Fade(e, { duration: 3.0 });
  });
}

// Centering pop-up windows (for Add to Duffel button)
function PopupCenter(pageURL, title,w,h) {
	var left = (screen.width/2)-(w/2);
	var top = (screen.height/2)-(h/2);
	var targetWin = window.open (pageURL, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
}

// // Ajax pagination used in Search
// Event.addBehavior.reassignAfterAjax = true;
// Event.addBehavior({
//     'div.pagination a' : Remote.Link
// })

// Show Div via javascript
function showLayer(layerName, shadowLayerName)
{
    if (document.getElementById) // Netscape 6 and IE 5+
    {
        var targetElement = document.getElementById(layerName);
        var shadowElement = document.getElementById(shadowLayerName);
        targetElement.style.top = shadowElement.style.top;
        targetElement.style.visibility = 'visible';
    }
}

// Hide Div via javascript
function hideLayer(layerName)
{
    if (document.getElementById) 
    {
        var targetElement = document.getElementById(layerName);
        targetElement.style.visibility = 'hidden';
    }
}


/****************
  Google Maps
*****************/

var markerHash = {};
var has_markers = false;
var googlebar_options = {
onSearchCompleteCallback : function(search) { search.results[0].streetAddress; },
onGenerateMarkerHtmlCallback : function(marker, html, result) { 
	var copy_url="http://duffelup.com/research/new?from_map=true&event_title=" + encodeURIComponent(result.titleNoFormatting) + "&idea_website=" + "&idea_phone=" + result.phoneNumbers[0].number + "&idea_address=" + encodeURIComponent(result.streetAddress) + ", " + encodeURIComponent(result.city) + ", " + encodeURIComponent(result.region) + " " + encodeURIComponent(result.country) 
	var copy_event = "<a href=\"" + copy_url + "\" onclick=\"window.open(this.href+'&jump=doclose', 'add_to_duffel', 'location=yes,links=no,scrollbars=no,toolbar=no,width=650,height=550');return false;\">Add to my duffel</a>"
	html.innerHTML += "<br/>" + copy_event; return html; }
};

function initialize_trip_map(gbar, gcontrol, show_bubble) {
	 if (GBrowserIsCompatible() && typeof ideas_to_map != 'undefined') {
	   	var map = new GMap2(document.getElementById("board_gmap"), {googleBarOptions: googlebar_options});
	   	map.setCenter(new GLatLng(37.7312, -122.383), 10);
			if (gcontrol) { // gcontrol = map type control
				map.addControl(new GLargeMapControl3D());
				map.addControl(new GMapTypeControl());
			} else {
				map.addControl(new GSmallZoomControl3D());
			}
			

			function addMarker(latlng, idea) {
				var html_event_type = null
				
				if (idea.index != null && idea.index > 0) {
					var numberedIcon = new GIcon();
					numberedIcon.shadow = "http://chart.apis.google.com/chart?chst=d_map_pin_shadow";
					numberedIcon.iconSize = new GSize(20, 34);
					numberedIcon.shadowSize = new GSize(37, 34);
					numberedIcon.iconAnchor = new GPoint(9, 34);
					numberedIcon.infoWindowAnchor = new GPoint(9, 2);
					numberedIcon.infoShadowAnchor = new GPoint(18, 25);
					if (idea.eventable_type == "Activity") {
						numberedIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + idea.index + "|99B91B|000000";
						html_event_type = "<p style=\"background-color:#b3d335;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Activity</p><br/>";
					}
					else if (idea.eventable_type == "Hotel") {
						numberedIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + idea.index + "|9E9E9E|000000";
						html_event_type = "<p style=\"background-color:#555;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Lodging</p><br/>";
					}
					else if (idea.eventable_type == "Foodanddrink") {
						numberedIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + idea.index + "|2DC6FF|000000";
						html_event_type = "<p style=\"background-color:#00aeef;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Food & Drink</p><br/>";
					}
					else if (idea.eventable_type == "CheckIn") {
						numberedIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + idea.index + "|cc66FF|000000";
						html_event_type = "<p style=\"background-color:#cc66ff;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Photo Spot</p><br/>";
					}
					var marker = new GMarker(latlng, numberedIcon);
				} else {
					var regularIcon = new GIcon();
					regularIcon.shadow = "http://chart.apis.google.com/chart?chst=d_map_pin_shadow";
					regularIcon.iconSize = new GSize(20, 34);
					regularIcon.shadowSize = new GSize(37, 34);
					regularIcon.iconAnchor = new GPoint(9, 34);
					regularIcon.infoWindowAnchor = new GPoint(9, 2);
					regularIcon.infoShadowAnchor = new GPoint(18, 25);
					if (idea.eventable_type == "Activity") {
						regularIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2%7C99B91B|000000";
						html_event_type = "<p style=\"background-color:#b3d335;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Activity</p><br/>";
					}
					else if (idea.eventable_type == "Hotel") {
						regularIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2%7C9E9E9E|000000";
						html_event_type = "<p style=\"background-color:#555;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Lodging</p><br/>";
					}
					else if (idea.eventable_type == "Foodanddrink") {
						regularIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2%7C2DC6FF|000000";
						html_event_type = "<p style=\"background-color:#00aeef;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Food & Drink</p><br/>";
					}
					else if (idea.eventable_type == "CheckIn") {
						regularIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2%7Ccc66FF|000000";
						html_event_type = "<p style=\"background-color:#cc66ff;position:absolute;color:#ffffff;font-size:12px;font-weight:bold;margin:0;padding:1px 3px;\">Photo Spot</p><br/>";
					}
					var marker = new GMarker(latlng, regularIcon);
				}
				if (idea.eventable_type == "CheckIn") {
					html_event_type = html_event_type + "<div style=\"text-align: center\"><img style=\"padding: 5px 0 0 9px;\" src='http://s3.amazonaws.com/duffelup_event_production/photos/"+idea.id+"/thumb/"+idea.photo_file_name+"'></div>"
					var html=html_event_type+"<div style=\"padding-top:4px;text-align: center;\"><strong>"+idea.title+"</strong><br/><div style=\"color:#777777;\">"+idea.note.truncate(500).gsub(/\n+/, '<br/>') + "</div>";
				} else {
					var html=html_event_type+"<div style=\"margin-top:3px; padding: 3px 0 0 9px; width: 300px;\"><strong>"+idea.title+"</strong><br/><div style=\"color:#777777;\">"+idea.address+"</div><br/>"+idea.note.truncate(500).gsub(/\n+/, '<br/>') + "</div>";
				}
				
				if (show_bubble) {
				GEvent.addListener(marker, "mouseover", function() {
						focusPoint(idea.id, html);
					});
				}

				map.addOverlay(marker);
				return marker;
			}

	    var bounds = new GLatLngBounds;
			for (var i=0; i<ideas_to_map.length; i++) {
				if (ideas_to_map[i].lat != null && ideas_to_map[i].lng != null) { // filters out ideas that don't have lat/lng
					var current = ideas_to_map[i];    	
					var latlng = new GLatLng(current.lat,current.lng);
					bounds.extend(latlng);
			    marker = addMarker(latlng, current);
					markerHash[current.id] = {marker:marker,visible:true,maker_index:i};
					has_markers = true;
				}
			}
	    map.setCenter(bounds.getCenter(),map.getBoundsZoomLevel(bounds));
			if (has_markers && gbar) { // only displays GoogleBar when there are stuff on map
				map.enableGoogleBar();
			}
		}
	
		//if (!has_markers && typeof display_update_button != 'undefined') {
			//alert ("Nothing to map!\n\nPlease add an address to Activity, Food & Drink, or Lodging so we can map it here.");
		//}
}

function simpleFormat(text) {
	//text = "<p>" + text
	text.gsub(/\n+/, '<br/>');
}

function focusPoint(id, html) {
	markerHash[id].marker.openInfoWindowHtml(html);
}

function initialize_city_map() {
	 if (GBrowserIsCompatible() && typeof cities_to_map != 'undefined') {
	   	map = new GMap2(document.getElementById("city_gmap"));
	   	map.setCenter(new GLatLng(37.7312, -122.383), 10);
			map.addControl(new GSmallZoomControl3D())
			map.addMapType(G_PHYSICAL_MAP);
			map.removeMapType(G_HYBRID_MAP);
			map.removeMapType(G_NORMAL_MAP);
			map.removeMapType(G_SATELLITE_MAP);
		
			// Clicking the marker will open it
	    function createMarker(latlng, city) {
				
				/*var droppinIcon = new GIcon();
				droppinIcon.shadow = "../images/drop-pin-shadow.png";
				droppinIcon.image = "../images/drop-pin.png"; 
				droppinIcon.iconSize = new GSize(8, 20);
				droppinIcon.shadowSize = new GSize(15, 14);
				droppinIcon.iconAnchor = new GPoint(9, 20);
				droppinIcon.infoWindowAnchor = new GPoint(9, 2);
				droppinIcon.infoShadowAnchor = new GPoint(18, 25);*/
				
				var max_width = 42
				var min_width = 15
				var min = 1
				var max = 10
				var width_diff = max_width - min_width
				
				var scale = width_diff / max_trip_count
				
				var iconOptions = {};
				iconOptions.width = Math.round(city.trip_count * scale) + 20;
				iconOptions.height = Math.round(city.trip_count * scale) + 20;
				iconOptions.primaryColor = "#2A3B4F";
				iconOptions.label = city.trip_count;
				iconOptions.labelSize = 13;
				iconOptions.labelColor = "#FFFFFF";
				iconOptions.shape = "circle";
				var droppinIcon = MapIconMaker.createFlatIcon(iconOptions);
				
				var marker = new GMarker(latlng, droppinIcon);
				
	      //var marker = new GMarker(latlng);
				if (city.city=="")
					var city_name = city.city_country;
				else
					var city_name = city.city;
				
	      var html="<strong>"+city.city_country+"</strong><br/>"+"<a href=\"http://duffelup.com/trips/new?city="+city.city_country+"\">Create a duffel to "+city_name+"</a><br/><br/>"+city.trip_count+" duffels  - <a href=\""+city.url+"\">View duffels &#187</a>";
	      GEvent.addListener(marker,"click", function() {
	        map.openInfoWindowHtml(latlng, html);
	      });
	      return marker;
	    }

	    var bounds = new GLatLngBounds;
			for (var i=0; i<cities_to_map.length; i++) {
				if (cities_to_map[i].latitude != null && cities_to_map[i].longitude != null) {
		    	var latlng=new GLatLng(cities_to_map[i].latitude,cities_to_map[i].longitude);
			    bounds.extend(latlng);
			    map.addOverlay(createMarker(latlng, cities_to_map[i]));
				}
			}
	    map.setCenter(bounds.getCenter(),map.getBoundsZoomLevel(bounds));
	 }
}

function initialize_idea_map() {
	 if (GBrowserIsCompatible() && typeof idea_to_map != 'undefined') {
	   var map = new GMap2(document.getElementById("gmap"));
	   map.setCenter(new GLatLng(37.7312, -122.383), 10);
		map.addControl(new GSmallZoomControl3D());
		
	    function createMarker(latlng, idea_to_map) {
	      var marker = new GMarker(latlng);
	      var html="<strong>"+idea_to_map.title+"</strong><br/>"+idea_to_map.address+"<br/>"+idea_to_map.phone;
	      //GEvent.addListener(marker,"click", function() {
	      //  map.openInfoWindowHtml(latlng, html);
	      //});
	      return marker;
	    }

    	var bounds = new GLatLngBounds;
	    var latlng=new GLatLng(idea_to_map.lat,idea_to_map.lng)
	    bounds.extend(latlng);
	    map.addOverlay(createMarker(latlng, idea_to_map));

	    map.setCenter(bounds.getCenter(),15);
	 }
}
