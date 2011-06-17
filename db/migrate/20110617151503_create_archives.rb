class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table :archives do |t|
      t.string :title
      t.string :url
      t.string :locale
      t.integer :position
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :archives
  end
end
