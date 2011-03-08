require 'spec_helper'

describe Landmark do
  fixtures :cities
  
  before(:each) do
    @valid_attributes = {
      :name => 'Wall Street',
      :city => cities(:new_york)
    }
  end

  it "should create a new instance given valid attributes" do
    Landmark.create!(@valid_attributes)
  end
end
