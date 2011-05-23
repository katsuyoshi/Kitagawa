class EventPresenter < ActiveRecord::Base
  belongs_to :event
  belongs_to :presenter
end
