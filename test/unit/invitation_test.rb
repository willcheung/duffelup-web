require File.dirname(__FILE__) + '/../test_helper'

class InvitationTest < ActiveSupport::TestCase

  fixtures :users, :trips
  
  def setup
    @user = users(:will)
    @trip = trips(:trip_1)
  end
  
  def test_invite
    Invitation.invite(@user, @trip)
    assert Invitation.exists?(@user, @trip)
    assert_status @user, @trip, 'not responded'
  end
  
  def test_reply_yes
    Invitation.invite(@user, @trip)
    Invitation.yes(@user, @trip)
    assert Invitation.exists?(@user, @trip)
    assert_status @user, @trip, 'yes'
  end
  
  def test_reply_maybe
    Invitation.invite(@user, @trip)
    Invitation.maybe(@user, @trip)
    assert Invitation.exists?(@user, @trip)
    assert_status @user, @trip, 'maybe'
  end
  
  def test_reply_no
    Invitation.invite(@user, @trip)
    Invitation.no(@user, @trip)
    assert Invitation.exists?(@user, @trip)
    assert_status @user, @trip, 'no'
  end
  
  # Verify the existence of an invitation with the given status.
  def assert_status(user, trip, status)
    invitation = Invitation.find_by_user_id_and_trip_id(user, trip)
    assert_equal status, invitation.status
  end
  
end
