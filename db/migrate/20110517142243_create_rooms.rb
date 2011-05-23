class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :code
      t.string :floor
      t.string :name
      t.integer :position
      t.string :locale

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end
