class DeleteTitleFromIdeas < ActiveRecord::Migration
  def self.up
    remove_column :ideas, :title
    add_column :events, :bookmarklet, :integer
  end

  def self.down
    add_column :ideas, :title, :string
    remove_column :events, :bookmarklet
  end
end
