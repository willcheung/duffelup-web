require 'spec_helper'

describe LandmarksController do

  before(:each) do
    @mock_city = mock_model(City, :landmarks => [])
    City.stub(:find).and_return(@mock_city)
    controller.stub!(:protect_admin_page)
  end
  
  def mock_landmark(stubs={})
    @mock_landmark ||= mock_model(Landmark, stubs)
  end

  describe "GET index" do
    it "assigns all landmarks as @landmarks" do
      @mock_city.landmarks.stub(:find).with(:all).and_return([mock_landmark])
      get :index
      assigns[:landmarks].should == [mock_landmark]
    end
  end

  describe "GET show" do
    it "assigns the requested landmark as @landmark" do
      @mock_city.landmarks.stub(:find).with("37").and_return(mock_landmark)
      get :show, :id => "37"
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "GET new" do
    it "assigns a new landmark as @landmark" do
      @mock_city.landmarks.stub(:new).and_return(mock_landmark(:build_stamp => true))
      get :new
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "GET edit" do
    it "assigns the requested landmark as @landmark" do
      @mock_city.landmarks.stub(:find).with("37").and_return(mock_landmark)
      get :edit, :id => "37"
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      before(:each) do
        mock_stamp = mock_model(Stamp, :valid? => true, :save => true)
        mock_landmark(:valid? => true, :save => true).stub(:build_stamp).and_return(mock_stamp)
        mock_landmark.stub(:stamp).and_return(mock_stamp)
      end
      
      it "assigns a newly created landmark as @landmark" do
        @mock_city.landmarks.stub(:new).with({'these' => 'params'}).and_return(mock_landmark)
        post :create, :landmark => {:these => 'params'}
        assigns[:landmark].should equal(mock_landmark)
      end

      it "redirects to the created landmark" do
        @mock_city.landmarks.stub(:new).and_return(mock_landmark)
        post :create, :landmark => {}
        response.should redirect_to(city_landmark_url(@mock_city, mock_landmark))
      end
    end

    describe "with invalid params" do
      before(:each) do
        mock_stamp = mock_model(Stamp)
        mock_landmark(:valid? => false).stub(:build_stamp).and_return(mock_stamp)
      end
      
      it "assigns a newly created but unsaved landmark as @landmark" do
        @mock_city.landmarks.stub(:new).with({'these' => 'params'}).and_return(mock_landmark)
        post :create, :landmark => {:these => 'params'}
        assigns[:landmark].should equal(mock_landmark)
      end

      it "re-renders the 'new' template" do
        @mock_city.landmarks.stub(:new).and_return(mock_landmark)
        post :create, :landmark => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      before(:each) do
        mock_stamp = mock_model(Stamp, :valid? => true, :save => true)
        mock_stamp.stub(:attributes=)
        mock_landmark(:valid? => true, :save => true).stub(:stamp).and_return(mock_stamp)
      end
      
      it "updates the requested landmark" do
        @mock_city.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
        mock_landmark.should_receive(:attributes=).with({'these' => 'params'})
        put :update, :id => "37", :landmark => {:these => 'params'}
      end

      it "assigns the requested landmark as @landmark" do
        @mock_city.landmarks.stub(:find).and_return(mock_landmark)
        mock_landmark.stub(:attributes=)
        put :update, :id => "1"
        assigns[:landmark].should equal(mock_landmark)
      end

      it "redirects to the landmark" do
        @mock_city.landmarks.stub(:find).and_return(mock_landmark)
        mock_landmark.stub(:attributes=)
        put :update, :id => "1"
        response.should redirect_to(city_landmark_url(@mock_city, mock_landmark))
      end
    end

    describe "with invalid params" do
      before(:each) do
        mock_stamp = mock_model(Stamp)
        mock_stamp.stub(:attributes=)
        mock_landmark(:valid? => false).stub(:stamp).and_return(mock_stamp)
      end
      
      it "updates the requested landmark" do
        @mock_city.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
        mock_landmark.should_receive(:attributes=).with({'these' => 'params'})
        put :update, :id => "37", :landmark => {:these => 'params'}
      end

      it "assigns the landmark as @landmark" do
        @mock_city.landmarks.stub(:find).and_return(mock_landmark)
        mock_landmark.stub(:attributes=)
        put :update, :id => "1"
        assigns[:landmark].should equal(mock_landmark)
      end

      it "re-renders the 'edit' template" do
        @mock_city.landmarks.stub(:find).and_return(mock_landmark)
        mock_landmark.stub(:attributes=)
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested landmark" do
      @mock_city.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
      mock_landmark.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the landmarks list" do
      @mock_city.landmarks.stub(:find).and_return(mock_landmark(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(city_landmarks_url(@mock_city))
    end
  end

end
