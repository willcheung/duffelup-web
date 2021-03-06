require 'spec_helper'

describe Achievement do
  before(:each) do
    @valid_attributes = {
      :user => mock_model(User),
      :stamp => mock_model(Stamp)
    }
  end

  it "should create a new instance given valid attributes" do
    Achievement.create!(@valid_attributes)
  end
end
