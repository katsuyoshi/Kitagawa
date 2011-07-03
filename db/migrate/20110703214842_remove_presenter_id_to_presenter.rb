class RemovePresenterIdToPresenter < ActiveRecord::Migration
  def self.up
    remove_column :presenters, :conference_id
    Presenter.delete_all
  end

  def self.down
    add_column :presenters, :conference_id, :integer
  end
end
