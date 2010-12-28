# To run this script: ruby /full/path/to/script/runner -e production "SessionCleaner.remove_stale_sessions"

class SessionCleaner
  def self.remove_stale_sessions
    CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_on <?', 20.minutes.ago] ) 
  end
  
  def self.list_sessions
    puts CGI::Session::ActiveRecordStore::Session
  end
end