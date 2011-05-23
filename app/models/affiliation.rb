class Affiliation < ActiveRecord::Base
  has_many :presenter_affiliations
  has_many :presenters, :through => :presenter_affiliations
end
