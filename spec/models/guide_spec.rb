require 'spec_helper'

describe Guide do
  fixtures :cities
  
  before(:each) do
    @valid_attributes = {
      :city => cities(:new_york)
    }
  end

  it "should create a new instance given valid attributes" do
    Guide.create!(@valid_attributes)
  end
end
