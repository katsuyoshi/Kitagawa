# -*- coding: utf-8 -*-
class Jrubykaigi2011Importer < YamlConferenceImporter

  def self.filename
    'jrubykaigi2011.yml'
  end
  
  def self.conference
    code = 'jrubykaigi2011'
    conference = Conference.find_by_code code
    if conference.nil?
      conference = Conference.create
      conference.code = code
      conference.title_ja ||= 'JRubyKaigi2011'
      conference.title_en ||= 'JRubyKaigi2011'
      if conference.changed?
        conference.save
      end
      conference.create_room_if_needs 'ORACLE', 'ja', 'オラクル青山センター13Fセミナー室', 1
      conference.create_room_if_needs 'ORACLE', 'en', 'オラクル青山センター13Fセミナー室', 1
    end
    conference
  end
  
end
