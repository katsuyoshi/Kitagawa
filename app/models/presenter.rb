class Presenter < ActiveRecord::Base
  has_many :event_presenters
  has_many :events, :through => :event_presenters
end
