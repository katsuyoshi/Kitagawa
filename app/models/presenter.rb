class Presenter < ActiveRecord::Base
  has_many :event_presenters
  has_many :events, :through => :event_presenters

  def hash_for_json
    {
      :presenter => {
        :name => self.name,
        :affiliation => self.affiliation,
        :bio => self.bio,
        :locale => self.locale,
      }
    }
  end
  
  def to_json
    hash_for_json.to_json
  end
  
end
