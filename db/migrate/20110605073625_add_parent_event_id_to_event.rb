class AddParentEventIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :parent_event_id, :integer
  end

  def self.down
    remove_column :events, :parent_event_id
  end
end
