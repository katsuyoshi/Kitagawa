class PresenterAffiliation < ActiveRecord::Base
  belongs_to :presenter
  belongs_to :affiliation
end
