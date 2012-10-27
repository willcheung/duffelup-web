# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Environment constants (for domain duffelup.com)
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LcpLQIAAAAAAICtw70ZNxLDseO9MhN-LNuxu9O8'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcpLQIAAAAAAPi8SBEKsqFBblq45pKszZ373-IF'

ENV['YELP_API_KEY'] = '1t_l-ZURPYb5K4nRKwZZvA'

ENV['TWITTER_CONSUMER_KEY'] = '0gXb6qUyeaZQVpUIjhJ6og'
ENV['TWITTER_CONSUMER_SECRET'] = 'F7neU7Xka7YzeNMKcMY8mKgOpjr5MeqOWRoZjTzWU'

ENV['INSTAGRAM_CLIENT_ID'] = '08396105047b4e758a46f223838755df'
ENV['INSTAGRAM_CLIENT_SECRET'] = 'fbbb9bfad5914dc2abd156e9117d2dff'

ENV['FLICKR_KEY'] = 'a1667fde25a098a17065eed3a145094c'
ENV['FLICKR_SECRET'] = '331b93c3dcb38585'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/sweepers )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'
  
  # Change where the cache is stored at
  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache"
  
  # action / fragment caching storage
  config.cache_store = :timed_file_store, RAILS_ROOT + "/public/cache"
  
  # Number migration
  config.active_record.timestamped_migrations = false

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_duffel_session',
    :secret      => '0c3b597ffa9540947505es38sa08deb4f4323febe201b5243befe69690876f2c5202e7611f3b7cf18e3f2ae39sb0f1l199ab6e4b2950f7ce33g'
  }
  
  DB_TEXT_MAX_LENGTH = 40000

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  
  # Amazon RightScale AWS
  config.gem 'right_aws'
  # Google's GData (gem contacts' dependent)
  config.gem 'gdata'
  # Contacts for importing email address from GMail, etc.
  config.gem 'contacts'
  # Twitter gem
  # config.gem 'twitter'
  # OAuth gem
  config.gem 'oauth'
  # Koala (Facebook) gem
  config.gem 'koala'
  # Instagram gem
  config.gem 'instagram'
end