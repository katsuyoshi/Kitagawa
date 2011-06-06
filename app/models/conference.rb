class Conference < ActiveRecord::Base
  has_many :days


  def hash_for_json
    {
      :ja => {
        :title => self.title_ja,
        :days => Day.all.map {|d| d.events.locale('ja').map {|e| e.hash_for_json}}
      },
      :en => {
        :title => self.title_en,
        :days => Day.all.map {|d| d.events.locale('en').map {|e| e.hash_for_json}}
      }
    }
  end
  

end
