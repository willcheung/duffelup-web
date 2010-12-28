class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :user_id, :trip_id, :null => false
      t.integer :user_type, :null => false
      t.integer :status, :null => false
      t.datetime :responded_at
      t.integer :email_update, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
