require 'spec_helper'

describe CheckInsController do
  fixtures :cities, :trips
  
  before(:each) do
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:load_trip_users)
    controller.stub!(:is_user_invited_to_trip).and_return(true)
  end
  
  def mock_check_in(stubs={})
    @mock_check_in ||= mock_model(CheckIn, stubs)
  end

  describe "GET index" do
    it "assigns all check_ins as @check_ins" do
      CheckIn.stub(:find).with(:all).and_return([mock_check_in])
      get :index
      assigns[:check_ins].should == [mock_check_in]
    end
  end

  describe "GET show" do
    it "assigns the requested check_in as @check_in" do
      CheckIn.stub(:find).with("37").and_return(mock_check_in)
      get :show, :id => "37"
      assigns[:check_in].should equal(mock_check_in)
    end
  end

  describe "GET new" do
    it "assigns a new check_in as @check_in" do
      CheckIn.stub(:new).and_return(mock_check_in)
      get :new
      assigns[:check_in].should equal(mock_check_in)
    end
  end

  describe "GET edit" do
    it "assigns the requested check_in as @check_in" do
      CheckIn.stub(:find).with("37").and_return(mock_check_in)
      get :edit, :id => "37"
      assigns[:check_in].should equal(mock_check_in)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created check_in as @check_in" do
        event = mock_model(Event)
        event.should_receive(:user=)
        event.should_receive(:bookmarklet=)
        CheckIn.stub(:new).with({'these' => 'params'}).and_return(mock_check_in(:save => true, :build_event => true,
          :event => event))
        post :create, :check_in => {:these => 'params'}
        assigns[:check_in].should equal(mock_check_in)
      end

      it "redirects to the created check_in" do
        event = mock_model(Event)
        event.should_receive(:user=)
        event.should_receive(:bookmarklet=)
        CheckIn.stub(:new).and_return(mock_check_in(:save => true, :build_event => true, :event => event))
        post :create, :check_in => {}
        response.should redirect_to(check_in_url(mock_check_in))
      end
      
      it 'creates an event for the check_in' do
        post :create, :check_in => { :lat => 37.5081, :lng => -122.301 },
          :event => { :trip_id => 1, :title => 'check_in' }
        assigns[:check_in].event.trip_id.should == 1
        response.should redirect_to(check_in_url(assigns[:check_in]))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved check_in as @check_in" do
        event = mock_model(Event)
        event.should_receive(:user=)
        event.should_receive(:bookmarklet=)
        CheckIn.stub(:new).with({'these' => 'params'}).and_return(mock_check_in(:save => false, :build_event => true,
          :event => event))
        post :create, :check_in => {:these => 'params'}
        assigns[:check_in].should equal(mock_check_in)
      end

      it "re-renders the 'new' template" do
        event = mock_model(Event)
        event.should_receive(:user=)
        event.should_receive(:bookmarklet=)
        CheckIn.stub(:new).and_return(mock_check_in(:save => false, :build_event => true, :event => event))
        post :create, :check_in => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested check_in" do
        CheckIn.should_receive(:find).with("37").and_return(mock_check_in)
        mock_check_in.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :check_in => {:these => 'params'}
      end

      it "assigns the requested check_in as @check_in" do
        CheckIn.stub(:find).and_return(mock_check_in(:update_attributes => true))
        put :update, :id => "1"
        assigns[:check_in].should equal(mock_check_in)
      end

      it "redirects to the check_in" do
        CheckIn.stub(:find).and_return(mock_check_in(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(check_in_url(mock_check_in))
      end
    end

    describe "with invalid params" do
      it "updates the requested check_in" do
        CheckIn.should_receive(:find).with("37").and_return(mock_check_in)
        mock_check_in.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :check_in => {:these => 'params'}
      end

      it "assigns the check_in as @check_in" do
        CheckIn.stub(:find).and_return(mock_check_in(:update_attributes => false))
        put :update, :id => "1"
        assigns[:check_in].should equal(mock_check_in)
      end

      it "re-renders the 'edit' template" do
        CheckIn.stub(:find).and_return(mock_check_in(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested check_in" do
      CheckIn.should_receive(:find).with("37").and_return(mock_check_in)
      mock_check_in.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the check_ins list" do
      CheckIn.stub(:find).and_return(mock_check_in(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(check_ins_url)
    end
  end

end
