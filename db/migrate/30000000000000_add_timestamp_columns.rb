class AddTimestampColumns < ActiveRecord::Migration
  def self.up
    add_column :ideas, :updated_at, :datetime
    add_column :ideas, :created_at, :datetime
    add_column :transportations, :updated_at, :datetime
    add_column :transportations, :created_at, :datetime
    add_column :events, :updated_at, :datetime
    add_column :events, :created_at, :datetime
  end

  def self.down
    remove_column :ideas, :updated_at
    remove_column :ideas, :created_at
    remove_column :transportations, :updated_at
    remove_column :transportations, :created_at
    remove_column :events, :updated_at
    remove_column :events, :created_at
  end
end
