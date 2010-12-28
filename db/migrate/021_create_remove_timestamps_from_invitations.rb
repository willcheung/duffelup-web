class CreateRemoveTimestampsFromInvitations < ActiveRecord::Migration
  def self.up
    remove_column :invitations, :created_at
    remove_column :invitations, :updated_at
    remove_column :invitations, :responded_at
  end

  def self.down
    add_column :invitations, :created_at, :datetime
    add_column :invitations, :updated_at, :datetime
    add_column :invitations, :responded_at, :datetime
  end
end
