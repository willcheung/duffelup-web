require 'spec_helper'

describe StampsController do
  fixtures :all
  
  before(:each) do
    controller.stub!(:logged_in?).and_return(true)
  end
  
  describe "GET index" do
    it "assigns all check_ins as @check_ins" do
      stamp = stamps(:statue_of_liberty)
      get :index
      assigns[:stamps].should == [stamp]
    end
  end

end
