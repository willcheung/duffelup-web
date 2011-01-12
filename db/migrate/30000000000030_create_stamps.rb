class CreateStamps < ActiveRecord::Migration
  def self.up
    create_table :stamps do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :stamps
  end
end
