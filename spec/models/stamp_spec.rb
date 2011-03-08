require 'spec_helper'

describe Stamp do
  before(:each) do
    @valid_attributes = {
      :name => "stamp name",
      :image_url => "image url"
    }
  end

  it "should create a new instance given valid attributes" do
    Stamp.create!(@valid_attributes)
  end
end
