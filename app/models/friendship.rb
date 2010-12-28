class Friendship < ActiveRecord::Base
  belongs_to :user
  # self-referal relationship
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user_id, :friend_id
  
  REQUESTED = 1
  PENDING = 2
  ACCEPTED = 3
  
  # Returns true if the users are (possibly) friends.
  def self.exists?(user, friend) 
    not find_by_user_id_and_friend_id(user, friend).nil?
  end
  
  # Add Duffel Guru as a contact
  def self.add_duffel_professor(user)
    professor = User.find_by_id(44)
    transaction do
      create(:user => user, :friend => professor, :status => Friendship::ACCEPTED, :accepted_at => Time.now)
      create(:user => professor, :friend => user, :status => Friendship::ACCEPTED, :accepted_at => Time.now)
    end
  end
  
  # Record a pending friend request.
  def self.request(user, friend)
    unless user == friend or Friendship.exists?(user, friend)
      transaction do
        create(:user => user, :friend => friend, :status => Friendship::PENDING)
        create(:user => friend, :friend => user, :status => Friendship::REQUESTED)
      end
    end
  end
  
  # Record a pending friend request and send email
  def self.request_and_send_email(user, friend, user_url, accept_url)
    unless user == friend or Friendship.exists?(user, friend)
      transaction do
        create(:user => user, :friend => friend, :status => Friendship::PENDING)
        create(:user => friend, :friend => user, :status => Friendship::REQUESTED)
      end
      
      Postoffice.deliver_friend_request(:user => user,
                                        :friend => friend,
                                        :user_url => user_url,
                                        :accept_url => accept_url) if !friend.email.blank?
    end
  end
  
  # Accept a friend request.
  def self.accept(user, friend)
    transaction do
      accepted_at = Time.now
      accept_one_side(user, friend, accepted_at)
      accept_one_side(friend, user, accepted_at)
    end
  end
  
  # Delete a friendship or cancel a pending request.
  def self.breakup(user, friend)
    transaction do
      destroy(find_by_user_id_and_friend_id(user, friend))
      destroy(find_by_user_id_and_friend_id(friend, user))
    end
  end
  
  private
  
  # Update the db with one side of an accepted friendship request.
  def self.accept_one_side(user, friend, accepted_at)
    request = find_by_user_id_and_friend_id(user, friend)
    request.status = Friendship::ACCEPTED
    request.accepted_at = accepted_at
    request.save!
  end
end