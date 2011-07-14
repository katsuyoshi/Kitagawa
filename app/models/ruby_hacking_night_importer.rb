# -*- coding: utf-8 -*-
class RubyHackingNightImporter < YamlConferenceImporter

  def self.filename
    'ruby_hacking_night.yml'
  end
  
  def self.conference
    code = 'ruby_hacking_night'
    conference = Conference.find_by_code code
    if conference.nil?
      conference = Conference.create
      conference.code = code
      conference.title_ja ||= 'Ruby会議４日目'
      conference.title_en ||= 'The 4th day of RubyKaigi'
      if conference.changed?
        conference.save
      end
    end
    conference.create_room_if_needs 'DAIBIRU', 'ja', '秋葉原ダイビル13F', 1
    conference.create_room_if_needs 'DAIBIRU', 'en', 'Akihabara Daibiru Bldg. 13F', 1
    conference
  end

  def self.data_file_key
    'ruby_hacking_night'
  end
  
end
