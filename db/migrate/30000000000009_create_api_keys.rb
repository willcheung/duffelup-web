class CreateApiKeys < ActiveRecord::Migration
  def self.up
    create_table :api_keys do |t|
      t.integer :user_id, :null => :false
      t.string  :key, :limit => 30
      t.string  :source, :limit => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :api_keys
  end
end
