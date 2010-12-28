require File.dirname(__FILE__) + '/../test_helper' 
require 'site_controller' 

# Re-raise errors caught by the controller. 
class SiteController; def rescue_action(e) raise e end; end 

class SiteControllerTest < Test::Unit::TestCase 
  def setup 
    @controller = SiteController.new 
    @request     = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new 
  end 

  def test_index 
    get :index 
    title = assigns(:title) 
    assert_equal "Welcome to Duffel Up", title 
    assert_response :success 
    assert_template "index" 
    end 

  def test_about 
    get :about 
    title = assigns(:title) 
    assert_equal "About Duffel Up", title 
    assert_response :success 
    assert_template "about" 
  end 

  def test_help 
    get :help 
    title = assigns(:title) 
    assert_equal "Duffel Up Help", title 
    assert_response :success 
    assert_template "help" 
  end 
  
  # Test the navigation menu before login.
  def test_navigation_not_logged_in
    get :index
    assert_tag "a", :content => /Sign Up/,
               :attributes => { :href => "/signup" }   
    assert_tag "a", :content => /Login/,
               :attributes => { :href => "/login" }
    assert_tag "a", :content => /About/,
              :attributes => { :href => "/about" }
    # Test link_to_unless_current.  
    assert_no_tag "a", :content => /Home/
  end
end 
