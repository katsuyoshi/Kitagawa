class AddGravatarToPresenter < ActiveRecord::Migration
  def self.up
    add_column :presenters, :gravatar, :string
  end

  def self.down
    remove_column :presenters, :gravatar
  end
end
