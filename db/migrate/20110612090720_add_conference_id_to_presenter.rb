class AddConferenceIdToPresenter < ActiveRecord::Migration
  def self.up
    add_column :presenters, :conference_id, :integer
  end

  def self.down
    remove_column :presenters, :conference_id
  end
end
