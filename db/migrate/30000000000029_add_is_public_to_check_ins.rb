class AddIsPublicToCheckIns < ActiveRecord::Migration
  def self.up
    add_column :check_ins, :is_public, :boolean, :default => 1
  end

  def self.down
    remove_column :check_ins, :is_public
  end
end
