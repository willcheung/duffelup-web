require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckIn do
  fixtures :cities, :guides, :landmarks, :trips, :users, :stamps
  
  before(:each) do
    @user = users(:quentin)
    @event = Event.create!(:trip_id => 1, :title => 'check_in')
    @event.user = @user
    @event.save!
    @valid_attributes = {
      :lat => 37.5081,
      :lng => -122.301,
      :event => @event
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
    CheckIn.find_landmark(40.409, -74.02).name.should == 'Statue of Liberty'
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
  
  describe "award stamp" do
    it "create achievement on user" do
      stamp = stamps(:statue_of_liberty)
      event = Event.create!(:trip_id => 1, :title => 'check_in')
      event.user = users(:will)
      event.save!
      lambda do
        check_in = CheckIn.create!(:lat => 40.41, :lng => -74.02, :event => event)
      end.should change(Achievement, :count).by(1)
      users(:will).stamps.should include stamp
    end
    
    it "does not create duplicate achievements" do
      stamp = stamps(:statue_of_liberty)
      event = Event.create!(:trip_id => 1, :title => 'check_in')
      event.user = users(:will)
      event.save!
      event.user.achievements.create!(:stamp => stamp)
      lambda do
        check_in = CheckIn.create!(:lat => 40.41, :lng => -74.02, :event => event)
      end.should_not change(Achievement, :count)
    end
    
    it "does not create achievement if landmark does not have a stamp" do
      stamps(:statue_of_liberty).destroy
      event = Event.create!(:trip_id => 1, :title => 'check_in')
      event.user = users(:will)
      event.save!
      lambda do
        check_in = CheckIn.create!(:lat => 40.41, :lng => -74.02, :event => event)
      end.should_not change(Achievement, :count)
    end
    
    it "does not create achievement if checkin is not close to a landmark" do
      event = Event.create!(:trip_id => 1, :title => 'check_in')
      event.user = users(:will)
      event.save!
      lambda do
        check_in = CheckIn.create!(:lat => 100, :lng => 100, :event => event)
      end.should_not change(Achievement, :count)
    end
    
    it "awards stamp if checkin close to landmark" do
      event = Event.create!(:trip_id => 1, :title => 'check_in')
      event.user = users(:quentin)
      event.save!
      stamp = stamps(:statue_of_liberty)
      # stamp = landmarks(:statue_of_liberty).create_stamp(:name => "freedom stamp", :image_url => "url")
      checkin = CheckIn.create!(:event => event,
        :lat => 40.409, :lng => -74.02)
      checkin.recently_achieved.should == stamp
      checkin.to_xml(:indent => 0).should include stamp.to_xml(:indent => 0, :skip_instruct => true)
    end
  end
  
  it "reports error if user bandwidth is over the bandwidth limit" do
    @user.bandwidth = User::UPLOAD_LIMIT
    @event.stub(:photo_file_size).and_return(1)
    check_in = CheckIn.create(:event => @event, :lat => 40.409, :lng => -74.02)
    check_in.errors.should_not be_empty
    check_in.errors.full_messages[0].should match /Event photo limit reached/
  end
end
