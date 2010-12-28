require "smtp_tls"

ENV['RAILS_ENV'] == 'production' ? file = "#{RAILS_ROOT}/config/mailer.yml" : file = "#{RAILS_ROOT}/config/gmail_mailer.yml"

mailer_config = File.open(file)
mailer_options = YAML.load(mailer_config)
ActionMailer::Base.smtp_settings = mailer_options