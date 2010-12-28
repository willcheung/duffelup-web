require 'spec_helper'

describe GuidesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/guides" }.should route_to(:controller => "guides", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/guides/new" }.should route_to(:controller => "guides", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/guides/1" }.should route_to(:controller => "guides", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/guides/1/edit" }.should route_to(:controller => "guides", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/guides" }.should route_to(:controller => "guides", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/guides/1" }.should route_to(:controller => "guides", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/guides/1" }.should route_to(:controller => "guides", :action => "destroy", :id => "1") 
    end
  end
end
