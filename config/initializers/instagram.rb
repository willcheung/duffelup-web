######### Instagram OAuth #########
Instagram.configure do |config|
  INSTAGRAM = YAML.load_file("#{RAILS_ROOT}/config/instagram.yml")[RAILS_ENV]
  
  config.client_id = INSTAGRAM['client_id']
  config.client_secret = INSTAGRAM['client_secret']
end