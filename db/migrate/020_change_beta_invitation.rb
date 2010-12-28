class ChangeBetaInvitation < ActiveRecord::Migration
  def self.up
    remove_column :beta_invitations, :user_id
    remove_column :beta_invitations, :invitation_code
    remove_column :beta_invitations, :invitations_available
    remove_column :beta_invitations, :invitations_sent
    remove_column :beta_invitations, :invitations_used
    add_column :beta_invitations, :sender_id, :integer
    add_column :beta_invitations, :recipient_email, :string
    add_column :beta_invitations, :token, :string
    add_column :beta_invitations, :sent_at, :datetime
    add_column :users, :beta_invitation_id, :integer
    add_column :users, :invitation_limit, :integer
  end

  def self.down
    # do nothing
  end
end
