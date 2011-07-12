# -*- coding: utf-8 -*-
class AutographRubykaigi2011Importer < YamlConferenceImporter

  def self.filename
    'autograph_rubykaigi2011.yml'
  end
  
  def self.conference
    code = 'rubykaigi2011'
    conference = Conference.find_by_code code
    conference.create_room_if_needs 'autograph', 'ja', 'サイン会', 3
    conference.create_room_if_needs 'autograph', 'en', 'Autograph Session', 3
    conference
  end

  def self.data_file_key
    'autograph_rubykaigi2011'
  end
  
end
