require 'spec_helper'

describe LandmarksController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/cities/1/landmarks" }.should route_to(:controller => "landmarks", :action => "index", :city_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/cities/1/landmarks/new" }.should route_to(:controller => "landmarks", :action => "new", :city_id => "1")
    end

    it "recognizes and generates #show" do
      { :get => "/cities/1/landmarks/1" }.should route_to(:controller => "landmarks", :action => "show", :id => "1", :city_id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/cities/1/landmarks/1/edit" }.should route_to(:controller => "landmarks", :action => "edit", :id => "1", :city_id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/cities/1/landmarks" }.should route_to(:controller => "landmarks", :action => "create", :city_id => "1") 
    end

    it "recognizes and generates #update" do
      { :put => "/cities/1/landmarks/1" }.should route_to(:controller => "landmarks", :action => "update", :id => "1", :city_id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/cities/1/landmarks/1" }.should route_to(:controller => "landmarks", :action => "destroy", :id => "1", :city_id => "1") 
    end
  end
end
