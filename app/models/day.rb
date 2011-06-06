class Day < ActiveRecord::Base
  belongs_to :conference
  has_many :events
  
  default_scope order('date')
  
  def hash_for_json
    {
      :day => {
        :date => self.date,
        :events => self.events.map {|e| e.hash_for_json}
      }
    }
  end
  
  def hash_for_json_with_locale locale
    {
      :days => {
        :date => self.date,
        :events => self.events.locale(locale).map {|e| e.hash_for_json}
      }
    }
  end
  
  def to_json
    hash_for_json.to_json
  end
  
end
