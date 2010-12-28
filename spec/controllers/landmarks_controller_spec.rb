require 'spec_helper'

describe LandmarksController do

  before(:each) do
    @mock_guide = mock_model(Guide, :landmarks => [])
    Guide.stub(:find).and_return(@mock_guide)
    controller.stub!(:protect_admin_page)
  end
  
  def mock_landmark(stubs={})
    @mock_landmark ||= mock_model(Landmark, stubs)
  end

  describe "GET index" do
    it "assigns all landmarks as @landmarks" do
      @mock_guide.landmarks.stub(:find).with(:all).and_return([mock_landmark])
      get :index
      assigns[:landmarks].should == [mock_landmark]
    end
  end

  describe "GET show" do
    it "assigns the requested landmark as @landmark" do
      @mock_guide.landmarks.stub(:find).with("37").and_return(mock_landmark)
      get :show, :id => "37"
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "GET new" do
    it "assigns a new landmark as @landmark" do
      @mock_guide.landmarks.stub(:new).and_return(mock_landmark)
      get :new
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "GET edit" do
    it "assigns the requested landmark as @landmark" do
      @mock_guide.landmarks.stub(:find).with("37").and_return(mock_landmark)
      get :edit, :id => "37"
      assigns[:landmark].should equal(mock_landmark)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created landmark as @landmark" do
        @mock_guide.landmarks.stub(:new).with({'these' => 'params'}).and_return(mock_landmark(:save => true))
        post :create, :landmark => {:these => 'params'}
        assigns[:landmark].should equal(mock_landmark)
      end

      it "redirects to the created landmark" do
        @mock_guide.landmarks.stub(:new).and_return(mock_landmark(:save => true))
        post :create, :landmark => {}
        response.should redirect_to(guide_landmark_url(@mock_guide, mock_landmark))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved landmark as @landmark" do
        @mock_guide.landmarks.stub(:new).with({'these' => 'params'}).and_return(mock_landmark(:save => false))
        post :create, :landmark => {:these => 'params'}
        assigns[:landmark].should equal(mock_landmark)
      end

      it "re-renders the 'new' template" do
        @mock_guide.landmarks.stub(:new).and_return(mock_landmark(:save => false))
        post :create, :landmark => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested landmark" do
        @mock_guide.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
        mock_landmark.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :landmark => {:these => 'params'}
      end

      it "assigns the requested landmark as @landmark" do
        @mock_guide.landmarks.stub(:find).and_return(mock_landmark(:update_attributes => true))
        put :update, :id => "1"
        assigns[:landmark].should equal(mock_landmark)
      end

      it "redirects to the landmark" do
        @mock_guide.landmarks.stub(:find).and_return(mock_landmark(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(guide_landmark_url(@mock_guide, mock_landmark))
      end
    end

    describe "with invalid params" do
      it "updates the requested landmark" do
        @mock_guide.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
        mock_landmark.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :landmark => {:these => 'params'}
      end

      it "assigns the landmark as @landmark" do
        @mock_guide.landmarks.stub(:find).and_return(mock_landmark(:update_attributes => false))
        put :update, :id => "1"
        assigns[:landmark].should equal(mock_landmark)
      end

      it "re-renders the 'edit' template" do
        @mock_guide.landmarks.stub(:find).and_return(mock_landmark(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested landmark" do
      @mock_guide.landmarks.should_receive(:find).with("37").and_return(mock_landmark)
      mock_landmark.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the landmarks list" do
      @mock_guide.landmarks.stub(:find).and_return(mock_landmark(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(guide_landmarks_url(@mock_guide))
    end
  end

end
