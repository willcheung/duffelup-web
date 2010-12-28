class CreateBetaInvitations < ActiveRecord::Migration
  def self.up
    create_table :beta_invitations do |t|
      t.integer :user_id
      t.string :invitation_code
      t.integer :invitations_available
      t.integer :invitations_sent
      t.integer :invitations_used
    end
  end

  def self.down
    drop_table :beta_invitations
  end
end
