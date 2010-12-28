class CreateTransportations < ActiveRecord::Migration
  def self.up
    create_table :transportations do |t|
      t.string :from, :to
      t.datetime :departure_time, :arrival_time
      t.timestamps
    end
  end

  def self.down
    drop_table :transportations
  end
end
