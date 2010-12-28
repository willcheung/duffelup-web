class AddPartnerToIdea < ActiveRecord::Migration
  def self.up
    add_column :ideas, :partner_id, :integer, :default => 0, :null => false
    add_column :events, :price, :float, :default => 0.0, :null => false
    add_column :events, :photo_file_name, :string # Original filename
    add_column :events, :photo_content_type, :string # Mime type
    add_column :events, :photo_file_size, :integer # File size in bytes
    change_column :viator_events, :price, :float
    change_column :viator_events, :avg_rating, :float
    remove_column :viator_events, :created_at
    remove_column :viator_events, :updated_at
  end

  def self.down
    remove_column :ideas, :partner_id
    remove_column :events, :price
    remove_column :events, :photo_file_name
    remove_column :events, :photo_content_type
    remove_column :events, :photo_file_size
  end
end
