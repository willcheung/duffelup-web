require File.dirname(__FILE__) + '/../test_helper'

class TripTest < ActiveSupport::TestCase
  
  fixtures :trips
  
  def setup 
    @error_messages = ActiveRecord::Errors.default_error_messages
    @trip = trips(:trip_1) 
  end
  
end
