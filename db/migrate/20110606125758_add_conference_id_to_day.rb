class AddConferenceIdToDay < ActiveRecord::Migration
  def self.up
    add_column :days, :conference_id, :integer
    
    rubykaigi2011 = Conference.find_by_code 'RubyKaigi2011'
    Day.all.each{|d| d.conference = rubykaigi2011; d.save}
  end

  def self.down
    remove_column :days, :conference_id
  end
end
