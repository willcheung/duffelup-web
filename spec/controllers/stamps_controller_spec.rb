require 'spec_helper'

describe StampsController do
  fixtures :all
  
  before(:each) do
    @user = users(:quentin)
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:current_user).and_return(@user)
  end
  
  describe "GET index" do
    it "assigns all stamps as @stamps" do
      get :index
      assigns[:stamps].size.should == 2
      assigns[:stamps].should include stamps(:jetsetter)
      assigns[:stamps].should include stamps(:statue_of_liberty)
    end
    
    it "set awarded_to_current_user for stamps achieved by the current user" do
      get :index
      assigns[:stamps].size.should == 2
      assigns[:stamps].any? { |s| s.id = stamps(:jetsetter).id && !s.awarded_to_current_user }.should be_true
      assigns[:stamps].any? { |s| s.id = stamps(:statue_of_liberty).id && s.awarded_to_current_user }.should be_true
    end
    
  end

end
