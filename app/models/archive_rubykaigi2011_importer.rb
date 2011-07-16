# -*- coding: utf-8 -*-
require 'importer'

class ArchiveRubykaigi2011Importer < Rubykaigi2011Importer

  # RubyKaigi 2011の記録のインポート
  # db/archives_of_rubykaigi2011.yml から設定
  def self.import
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db/archives_of_rubykaigi2011.yml'), 'archives_of_rubykaigi2011'
    if yaml
      self.parse_archives_of_rubykaigi2011_with_locale_and_events 'ja', yaml['events']
      self.parse_archives_of_rubykaigi2011_with_locale_and_events 'en', yaml['events']
    end
  end
  
  def self.data_file_key
    'archives_of_rubykaigi2011'
  end
  
end
