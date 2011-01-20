#require File.dirname(__FILE__)+'/common'

require 'yaml'

def load_database_yml(env)
  dbc = YAML.load(File.open("config/database.yml"))[env]
  user = dbc['username']
  pass = dbc['password']
  host = dbc['host']
  dbname = dbc['database']
  [host, dbname, user, pass]
end

LOG_PATH="/app/duffelup/shared/mysql_backups"

## 
## Backup and restore scripts for MySQL backed Rails apps
##
## HOW TO USE:
##
## Backup production database
##   >> RAILS_ENV=production rake db:mysql:backup
## Restore production database
##   >> RAILS_ENV=production rake db:mysql:restore backup=app_2008-01-04_17-13-04_production_mysql.sql.bz2

namespace :db do
  namespace :mysql do
    
    desc "Backup the database to a file (defaults to development)"
    task :backup => :environment do
      env = RAILS_ENV
      datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      file = "app_#{datestamp}_#{env}_mysql.sql.bz2"
      h, d, u, p = load_database_yml(env)
      `mkdir -p #{LOG_PATH}`
      
      puts "Backing #{env.upcase} to #{LOG_PATH}/#{file}"
      cmd = "mysqldump #{d} -u#{u} -p#{p} -h#{h} | bzip2 > #{LOG_PATH}/#{file}"
      `#{cmd}`
    end
    
    desc "Restore the RAILS_ENV database from a backup file. e.g. backup=app_2008-01-04_17-13-04_production_mysql.sql.bz2"
    task :restore => :environment do
      unless ENV.include?("backup")
        puts `ls -lc #{LOG_PATH}/*.sql.bz2`
        raise "Usage: RAILS_ENV=production rake db:msql:restore backup=app_2008-01-04_17-13-04_production_mysql.sql.bz2"    
      end
      file = "#{LOG_PATH}/#{ENV['backup']}"
      puts file
      raise "Backup file does not found" unless File.exists?(file)
      
      env = RAILS_ENV
      h, d, u, p = load_database_yml(env)
      
      puts "Restoring #{env.upcase} with #{file}"
      
      Rake::Task["db:mysql:drop_db"].invoke
      Rake::Task["db:mysql:create_db"].invoke

      cmd = "bzcat #{file} | mysql #{d} -u#{u} -p#{p} -h#{h}"
      puts "\nUnzipping: #{cmd}"
      `#{cmd}`
    end
    
    task :drop_db => :environment do
      env = RAILS_ENV
      h, d, u, p = load_database_yml(env)
      cmd = "yes | mysqladmin drop #{d} -u#{u} -p#{p} -h#{h}"
      puts "\nDropping database: #{cmd}"
      `#{cmd}`
    end
   
    task :create_db => :environment do
      env = RAILS_ENV
      h, d, u, p = load_database_yml(env)
      cmd = "mysqladmin create #{d} -u#{u} -p#{p} -h#{h}"
      puts "\nCreating database: #{cmd}"
      `#{cmd}`
    end
    
    namespace :schema do
      desc "Report the current version of the RAILS_ENV database schema."
      task :version => :environment do
        r = ActiveRecord::Base.connection.execute "SELECT version FROM schema_info LIMIT 1"
        puts "SCHEMA VERSION: #{r.fetch_row}"
      end
    end

  end
end
