class Archive < ActiveRecord::Base
  belongs_to :event
  
  default_scope order('position')

  def hash_for_json
    { :title => self.title, :url => self.url, :position => self.position }
  end
end
