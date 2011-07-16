# -*- coding: utf-8 -*-
class YamiRubykaigiImporter < Rubykaigi2011Importer

  def self.filename
    'yami_rubykaigi.yml'
  end
  
  def self.conference
    code = 'rubykaigi2011'
    Conference.find_by_code code
  end

  def self.import
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db', self.filename), self.data_file_key
p yaml
    if yaml
      import_yami_rubykaigi yaml
    end
  end

  def self.data_file_key
    'yami_rubykaigi'
  end
  

private

  def self.import_yami_rubykaigi info
    conference = self.conference
p conference
    parent = conference.events.find_by_code info['parent_id']
p parent
    info['sub_events'].each do |sub_event_info|
      self.parse_sub_event_of_event parent, 'ja', sub_event_info
      self.parse_sub_event_of_event parent, 'en', sub_event_info
    end
  end
  
end
