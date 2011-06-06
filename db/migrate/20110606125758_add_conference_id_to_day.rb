class AddConferenceIdToDay < ActiveRecord::Migration
  def self.up
    add_column :days, :conference_id, :integer
    add_column :rooms, :conference_id, :integer
    add_column :events, :conference_id, :integer
  end

  def self.down
    remove_column :days, :conference_id
  end
end
