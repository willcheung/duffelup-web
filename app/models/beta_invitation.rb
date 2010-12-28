class BetaInvitation < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  # validates_presence_of :recipient_email, :if => :sender
  # validate :recipient_is_not_registered, :if => :sender
  # validates_format_of :recipient_email, 
  #                         :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i, 
  #                         :message => "must be a valid email address",
  #                         :if => :sender

  before_create :generate_token
  
  private

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if User.find_by_email(recipient_email)
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

end
