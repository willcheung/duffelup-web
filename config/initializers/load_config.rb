# config/initializers/load_config.rb
FB_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/facebooker.yml")[RAILS_ENV]