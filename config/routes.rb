ActionController::Routing::Routes.draw do |map|

  map.resources :cities do |city|
    city.resources :landmarks
  end
  
  map.resources :guides

  map.resources :check_ins, :collection => { :near_by => :get }
  map.resource :subscription
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # restful_authentication stuff
  map.resource :user, :collection => {:link_user_accounts => :get}
  map.resource :session
  map.twitter_callback_session 'session/twitter_callback', :controller => 'sessions', :action => 'twitter_callback'
  
  # bookmarklet
  map.resource :research
  
  # featured
  map.resources :featured_duffels, :as => 'featured'
  
  map.resources :trips do |trip| 
    trip.resources :comments, :path_prefix => 'trips/:permalink'
    trip.resources :ideas, :controller => 'events', :path_prefix => 'trips/:permalink'
    
    #trip.details 'details', :controller => 'comments', :action => 'index', :path_prefix => 'trips/:permalink'
    #trip.sync_itinerary 'sync_itinerary', :controller => 'webapps', :action => 'sync_itinerary', :path_prefix => 'trips/:permalink', :conditions => { :method => :get }
    trip.print_itinerary 'print_itinerary', :controller => 'trips', :action => 'print_itinerary', :path_prefix => 'trips/:permalink', :conditions => { :method => :get }
    trip.show_map 'show_map', :controller => 'trips', :action => 'show_map', :path_prefix => 'trips/:permalink', :conditions => { :method => :get }
    
    trip.invitation 'invite', :controller => 'invitation', :action => 'index', :path_prefix => 'trips/:permalink'
    trip.create_invitation 'invite/create_invite', :controller => 'invitation', :action => 'create', :path_prefix => 'trips/:permalink'
    trip.favorite 'favorite', :controller => 'favorite', :action => 'index', :path_prefix => 'trips/:permalink'
    trip.create_favorite 'favorite/create',  :controller => 'favorite', :action => 'create', :path_prefix => 'trips/:permalink'
    trip.delete_favorite 'favorite/delete',  :controller => 'favorite', :action => 'delete', :path_prefix => 'trips/:permalink'
    trip.share 'share', :controller => 'trips', :action => 'share', :path_prefix => 'trips/:permalink'
  end
  
  # Change /trips to /explore
  map.explore 'explore', :controller => 'trips', :action => 'index'
  map.search 'search', :controller => 'site', :action => 'search'
  
  # announcements
  map.hide_announcement 'announcements/hide', :controller => 'announcements', :action => 'hide_announcement'
  map.resources :announcements
  
  map.resources :beta_invitations, :as => 'duffel_invitations'
  
  # user / session controllers
  map.password '/user/password', :controller => 'users', :action => 'password'
  map.user_search '/user/search', :controller => 'users', :action => 'search'
  map.avatar '/user/avatar', :controller => 'users', :action => 'avatar'
  map.steptwo '/user/bookmarklet', :controller => 'users', :action => 'steptwo'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.bookmarklet_login  '/bookmarklet_login', :controller => 'sessions', :action => 'new_session_bookmarklet'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "site", :action => "index", :id => nil
  
  # site controller
  map.feedback '/site/feedback', :controller => 'site', :action => 'feedback'
  map.ian_header '/site/ian_header.html', :controller => 'site', :action => 'ian_header' 
  map.hotels 'hotels', :controller => 'site', :action => 'splendia_hotels'
  map.activities 'activities', :controller => 'site', :action => 'viator_activities'
  
  # profile controller
  map.profile ':username', :controller => 'profile', :action => 'show'
  map.formatted_profile ':username.:format', :controller => 'profile', :action => 'show'
  map.dashboard '/user/dashboard', :controller => 'users', :action => 'show'
  
  # Widgets
  map.connect '/widget/:action/:api_key', :controller => 'widget', :api_key => /.*/
  
  # Admin
  map.connect '/admin/:action', :controller => 'admin', :action => 'index'
  
  # Business
  map.connect '/business/:action', :controller => 'business'
    
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # cities / countries controller
  map.country 'country/:country_code', :controller => 'cities', :action => 'country'
  map.city ':country_code/:city', :controller => 'cities', :action => 'index'
  map.city_duffels ':country_code/:city/duffels', :controller => 'cities', :action => 'duffels'
  map.na_city ':country_code/:region/:city', :controller => 'cities', :action => 'index'
  map.na_city_duffels ':country_code/:region/:city/duffels', :controller => 'cities', :action => 'duffels'
end
