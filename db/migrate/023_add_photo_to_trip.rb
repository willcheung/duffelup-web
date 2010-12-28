class AddPhotoToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :photo_file_name, :string
    add_column :trips, :photo_content_type, :string
    add_column :trips, :photo_file_size, :integer
    remove_column :trips, :description
    remove_column :trips, :can_invite_friends
  end

  def self.down
    remove_column :trips, :photo_file_name
    remove_column :trips, :photo_content_type
    remove_column :trips, :photo_file_size
    add_column :trips, :description, :text
    add_column :trips, :can_invite_friends, :integer
  end
end
