require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :create, :username => 'quentin', :password => 'testing'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_with_wrong_password_and_redirect
    post :create, :username => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :redirect
  end
  
  def test_should_fail_login_with_nonexistent_username_and_redirect
    post :create, :username => 'nosuchuser', :password => 'bad password'
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :username => 'quentin', :password => 'testing', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :username => 'quentin', :password => 'testing', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
