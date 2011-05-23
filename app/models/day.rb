class Day < ActiveRecord::Base
  has_many :events
  
  default_scope order('date')
end
