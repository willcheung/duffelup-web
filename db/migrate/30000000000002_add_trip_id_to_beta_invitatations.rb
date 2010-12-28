class AddTripIdToBetaInvitatations < ActiveRecord::Migration
  def self.up
    add_column :beta_invitations, :trip_id, :integer
  end

  def self.down
    remove_column :beta_invitations, :trip_id
  end
end
