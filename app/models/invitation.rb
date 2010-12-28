class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :trip
  
  validates_presence_of :user, :trip
  
  YES = 1
  NO = 2            # not used
  NOT_RESPONDED = 3 # not used
    
  USER_TYPE_ADMIN = 1
  USER_TYPE_MEMBER = 2
  
  # Return true if the users are invited to a trip.
  def self.exists?(user, trip)
    not find_by_user_id_and_trip_id(user, trip).nil?
  end
  
  # Create a self invitation (when creating a new trip) and respond 'yes'
  def self.invite_self(user, trip)
    #unless Invitation.exists?(user, trip)
      create(:user => user, :trip => trip, :user_type => Invitation::USER_TYPE_ADMIN, :status => Invitation::YES)
    #end
  end
  
  # Send an invitation to a trip and automatically respond 'yes'
  def self.invite(user, trip)
    unless Invitation.exists?(user.id, trip.id)
      create(:user => user, :trip => trip, :user_type => Invitation::USER_TYPE_MEMBER, :status => Invitation::YES)
    end
  end
  
  # Prases a string of emails.  Only first 5 emails will be read and validated.  
  # Returns an array of 5 valid emails or false.
  def self.parse_and_validate_emails(string)    
    if string.nil? or string.empty?
      return false
    end
    
    e = string.split(';')
    emails = e[0..9]
    emails.each do |email|
      email.strip!
      unless email =~ /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
        return false
      end
    end
    
    return emails
  end
  
  # Respond 'yes' to a trip.
  # Do not use.
  def self.yes(user, trip)
    respond(user, trip, Invitation::YES)
  end
  
  # Respond 'no' to a trip.
  # Do not use.
  def self.no(user, trip)
    respond(user, trip, Invitation::NO)
  end
  
  private
  
  # Respond a response to a trip
  # Do not use.
  def self.respond(user, trip, response)
    invitation = find_by_user_id_and_trip_id(user, trip)
    # invitation.responded_at = Time.now
    invitation.status = response
    invitation.save!
  end
  
end
