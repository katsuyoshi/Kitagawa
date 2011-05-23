class Presenter < ActiveRecord::Base
  has_many :event_presenters
  has_many :events, :through => :event_presenters
  
  has_many :presenter_affiliations
  has_many :affiliations, :through => :presenter_affiliations
end
