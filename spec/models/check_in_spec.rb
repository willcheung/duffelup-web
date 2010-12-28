require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckIn do
  fixtures :cities, :guides, :landmarks, :trips
  
  before(:each) do
    @valid_attributes = {
      :lat => 37.5081,
      :lng => -122.301,
      :event => Event.create!(:trip_id => 1, :title => 'check_in')
    }
  end

  it "should create a new instance given valid attributes" do
    check_in = CheckIn.create!(@valid_attributes)
    check_in.city.city_country.should == 'Belmont, CA, United States'
  end
  
  it 'finds a city based on lag long' do
    CheckIn.find_city(37.5081, -122.301).city_country.should == 'Belmont, CA, United States'
  end
  
  it 'finds a landmark based on lag long' do
    CheckIn.find_landmark(40.4, -74.02).name.should == 'Statue of Liberty'
  end
  
  describe 'trip date slots' do
    it 'slots the checkin into the correct date' do
      Time.stub!(:now).and_return(Time.local(2030, 7, 9, 13, 50))
      check_in = CheckIn.create!(@valid_attributes)
      check_in.event.list.should == 3
      
      Time.stub!(:now).and_return(Time.local(2030, 7, 10, 13, 50))
      check_in = CheckIn.create!(@valid_attributes)
      check_in.event.list.should == 4
    end
    
    it 'slots the checkin in default if checkin date is before or after the trip' do
      Time.stub!(:now).and_return(Time.local(2030, 7, 1, 13, 50))
      check_in = CheckIn.create!(@valid_attributes)
      check_in.event.list.should == 0
      
      Time.stub!(:now).and_return(Time.local(2030, 7, 11, 13, 50))
      check_in = CheckIn.create!(@valid_attributes)
      check_in.event.list.should == 0
    end
    
  end
end
