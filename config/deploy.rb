set :application, "duffelup"
set :user, "duffelup"
set :repository,  "https://subversion.assembla.com/svn/duffelup-web"

set :runner, user

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

#set :port, 8888
set :deploy_to, "/app/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "duffelup.com"
role :web, "duffelup.com"
role :db,  "duffelup.com", :primary => true

set :deploy_via, :copy

namespace :deploy do
#############################################################
#	Passenger
#############################################################

  namespace :passenger do
    desc "Restart Application"
    task :restart, :roles => :app do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

  # custom task to stop Apache
  desc "duffel - Stops web server"
  task :stop_web_server, :roles => :web do
    sudo "/etc/init.d/httpd stop"
    run "sleep 10"
  end

  # custom taks to start Apache
  desc "duffel - Starts web server"
  task :start_web_server, :roles => :web do
    sudo "/etc/init.d/httpd start"
  end

  # restart Apache web server
  desc "duffel - Restarts web server"
  task :restart_web_server, :roles => :web do
  	sudo "/etc/init.d/httpd restart"
  end

  desc "Copy production database.yml."
  task :copy_database_configuration do
      production_db_config = "/app/duffelup/prod/production.database.yml"
      run "cp #{production_db_config} #{release_path}/config/database.yml"
  end
  
  namespace :assets do
    desc "Point assets to shared directories."
    	task :symlink, :roles => :app do
  	    assets.create_dirs
        run <<-CMD
          rm -rf #{release_path}/public/avatars &&
          ln -nfs #{shared_path}/avatars #{release_path}/public/avatars &&
          ln -nfs #{shared_path}/system #{release_path}/public/system &&
          ln -nfs #{shared_path}/sitemaps #{release_path}/public/sitemaps &&
          ln -nfs #{shared_path}/cities #{release_path}/public/images/cities &&
          ln -nfs #{shared_path}/cache #{release_path}/public/cache &&
          ln -nfs #{shared_path}/press #{release_path}/public/images/press
        CMD
      end
  
      task :create_dirs, :roles => :app do
        %w(avatars).each do |name|
          run "mkdir -p #{shared_path}/#{name}"
        end
      end
    end
  
    desc "Send email to engineering after deployment"
      task :send_email do
        run "echo \"Code deployed!  This email doesn't indicate whether deployment succeeded or not (nor provide any other info, as a matter of fact), so you better check whether the the site is still up!\" | mail -s \"Admin just deployed code to production\" engineering@duffelup.com"
    end

    after "deploy:update_code", "deploy:copy_database_configuration"
    after "deploy:update_code", "deploy:assets:symlink"
    after "deploy:update_code", "deploy:passenger:restart"
    after "deploy:update_code", "deploy:send_email"
    after "deploy", "deploy:cleanup"
end
