class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.string :kind
      t.text :abstract
      t.string :locale
      t.string :language
      t.string :code
      t.datetime :start_at
      t.datetime :end_at
      t.integer :position
      t.integer :day_id
      t.integer :room_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
