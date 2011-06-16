class Presenter < ActiveRecord::Base
  has_many :event_presenters
  has_many :events, :through => :event_presenters
  belongs_to :conference

  def hash_for_json
    {
      :presenter => {
        :code => self.code,
        :name => self.name,
        :gravatar => self.gravatar,
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
