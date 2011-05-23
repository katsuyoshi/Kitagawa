class CreateEventPresenters < ActiveRecord::Migration
  def self.up
    create_table :event_presenters do |t|
      t.integer :event_id
      t.integer :presenter_id
      t.integer :presenter_position

      t.timestamps
    end
  end

  def self.down
    drop_table :event_presenters
  end
end
