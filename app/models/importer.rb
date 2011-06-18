# -*- coding: utf-8 -*-
require 'open-uri'

class Importer

  # RubyKaigi 2011のインポート
  def self.import_rubykaigi2011_from_json_file path
    parser = nil
    open(path) do |f|
      last_data = DataFile.find_or_create_by_key('rubykaigi2011')
      context = f.read
      # 前回と同じなら更新しない
      if last_data.context == context
        return
      end
      last_data.context = context
      last_data.save
      parser = JSON.parser.new context
    end

    timetables = parser.parse['timetable']
    parse_rubykaigi2011_with_locale_and_timetalbes 'ja', timetables
    parse_rubykaigi2011_with_locale_and_timetalbes 'en', timetables    
  end
  
  # RubyKaigi 2011のLTインポート
  # とりあえず db/lightning_talks_of_rubykaigi2011.yml から設定
  # 公式の発表があったら変更になる
  def self.import_lightning_talks_of_rubykaigi2011
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db/lightning_talks_of_rubykaigi2011.yml'), 'lightning_talks_of_rubykaigi2011'
    if yaml
      parse_lightning_talks_of_rubykaigi2011_with_locale_and_events 'ja', yaml['events']
      parse_lightning_talks_of_rubykaigi2011_with_locale_and_events 'en', yaml['events']
    end
  end
  
  # RubyKaigi 2011の記録のインポート
  # db/archives_of_rubykaigi2011.yml から設定
  def self.import_archives_of_rubykaigi2011
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db/archives_of_rubykaigi2011.yml'), 'archives_of_rubykaigi2011'
    if yaml
      parse_archives_of_rubykaigi2011_with_locale_and_events 'ja', yaml['events']
      parse_archives_of_rubykaigi2011_with_locale_and_events 'en', yaml['events']
    end
  end
  
  # JRubyKaigi 2011の記録のインポート
  # db/jrubykaigi2011.yml から設定
  def self.import_jrubykaigi2011
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db/jrubykaigi2011.yml'), 'jrubykaigi2011'
    if yaml
      conference = Conference.jrubykaigi2011
      parse_conference_with_locale_and_timetable conference, 'ja', yaml['timetable']
      parse_conference_with_locale_and_timetable conference, 'en', yaml['timetable']
    end
  end



private

  # yamlファイルの読み込み
  # 前回処理したデータと同じならnilを返す
  def self.load_yaml_file_with_key path, key
    open(path) do |f|
      last_data = DataFile.find_or_create_by_key(key)
      context = f.read
      # 前回と同じなら更新しない
      if last_data.context == context
        return nil
      end
      last_data.context = context
      last_data.save
    end
    YAML.load_file path
  end


  # RubyKaigi 2011のJSONデータのバース
  def self.parse_rubykaigi2011_with_locale_and_timetalbes locale, timetables 
    conference = Conference.rubykaigi2011
           
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    days = timetables.keys.sort
    days.each do |d|
    
      day = conference.days.find_or_create_by_date Date.parse(d)
      timetables[d].each do |e|
        room = conference.rooms.find_by_locale_and_code locale, e['room_id']
        index = 1
        index_dict_for_special_event = {}
        e['sessions'].each do |s|
          start_at = Time.parse s['start']
          end_at = Time.parse s['end']
          s['events'].each do |ev|
            type = ev['_id']
            case type
            when 'announcement', 'break', 'dinner', 'lunch', 'open', 'party', 'transit_time'
              code = index_dict_for_special_event[type]
              code ||= 1
              index_dict_for_special_event[type] = code + 1
              code = "#{d}:#{room.code}:#{type}:#{code}"
            else
              code = type
              type = 'session'
            end
            
            event = conference.events.find_or_create_by_locale_and_code locale, code
            event.kind = type
            event.title = ev['title'][locale] || ev['title'][contrary_locale]
            event.abstract = ev['abstract'] ? ev['abstract'][locale] || ev['abstract'][contrary_locale] : nil
            event.start_at = start_at
            event.end_at = end_at
            event.room = room
            event.language = ev['language']
            event.position = index
            day.events << event unless event.day
            event.save if event.changed?
            
            ev['presenters'].each_with_index do |pr, i|
            
              name = pr['name'][locale] || pr['name'][contrary_locale]
              bio = pr['bio'][locale] || pr['bio'][contrary_locale] if pr['bio']
              affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']
              
              presenter = conference.presenters.find_or_create_by_locale_and_name locale, name
              presenter.code ||= "#{event.code}:#{i + 1}"
              presenter.gravatar = pr['gravatar']
              presenter.bio ||= bio
              presenter.affiliation = affiliation
              presenter.save if presenter.changed?
              event.presenters << presenter unless event.presenters.include? presenter
              
            end if ev['presenters']
            
            index = index + 1
          end
        end
        
      end
    end
    
  end

  # RubyKaigi 2011のLTデータのバース
  def self.parse_lightning_talks_of_rubykaigi2011_with_locale_and_events locale, events
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    h = {}
    
    events.each do |e|
      parent_code = e['parent_code']
      parent = Event.find_by_code_and_locale parent_code, locale
      if parent
        position = h[parent_code]
        position = position ? position + 1 : 1
        h[parent_code] = position
        
        code = "#{parent_code}:#{position}"
        event = parent.sub_events.find_or_create_by_code_and_locale(code, locale)
        event.kind = 'session'
        event.title = e['title'][locale] || e['title'][contrary_locale]
        event.abstract = e['abstract'][locale] || e['abstract'][contrary_locale]
        event.room = parent.room
        event.start_at = parent.start_at
        event.end_at = parent.end_at
        event.position = position
        event.save if event.changed?

        e['presenters'].each_with_index do |pr, i|
            
          name = pr['name'][locale] || pr['name'][contrary_locale]
          bio = pr['bio'][locale] || pr['bio'][contrary_locale] if pr['bio']
          affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']
              
          presenter = conference.presenters.find_or_create_by_locale_and_name locale, name
          presenter.code ||= "#{event.code}:#{i + 1}"
          presenter.gravatar = pr['gravatar']
          presenter.bio ||= bio
          presenter.affiliation = affiliation
          presenter.save if presenter.changed?
          event.presenters << presenter unless event.presenters.include? presenter
              
        end if e['presenters']
      end
    end
  end
  
  # RubyKaigi 2011の記録のパース
  def self.parse_archives_of_rubykaigi2011_with_locale_and_events locale, events
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    events.each do |e|
      e = e['event']
      event = Event.find_by_code_and_locale e['code'], locale
      deleted_archives = event.archives.clone
      if event
        e['archives'].each_with_index do |a, index|
          archive = event.archives.find_or_create_by_url_and_locale a['url'], locale
          archive.title = a['title'][locale] || a['title'][contrary_locale]
          archive.position = index + 1
          archive.save
          deleted_archives.delete archive
        end
        deleted_archives.each do |a|
          a.destroy
        end
      end
    end
  end
  

  
  # JRubyKaigi 2011のパース
  # conferenceを変えればJRubyKaigi以外にも使えるつもり
  def self.parse_conference_with_locale_and_timetable conference, locale, timetables

    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    days = timetables.keys.sort
    days.each do |d|

      day = conference.days.find_or_create_by_date Date.parse(d)
      timetables[d].each do |e|
        room = conference.rooms.find_by_locale_and_code locale, e['room_id']
        index = 1
        index_dict_for_special_event = {}
        e['sessions'].each do |s|
          start_at = Time.parse s['start']
          end_at = Time.parse s['end']
          s['events'].each do |ev|
            type = ev['_id']
            case type
            when 'announcement', 'break', 'dinner', 'lunch', 'open', 'party', 'transit_time'
              code = index_dict_for_special_event[type]
              code ||= 1
              index_dict_for_special_event[type] = code + 1
              code = "#{d}:#{room.code}:#{type}:#{code}"
            else
              code = type
              type = 'session'
            end
            
            event = conference.events.find_or_create_by_locale_and_code locale, code
            event.kind = type
            event.title = ev['title'][locale] || ev['title'][contrary_locale]
            event.abstract = ev['abstract'] ? ev['abstract'][locale] || ev['abstract'][contrary_locale] : nil
            event.start_at = start_at
            event.end_at = end_at
            event.room = room
            event.language = ev['language']
            event.position = index
            day.events << event unless event.day
            event.save if event.changed?
            
            ev['presenters'].each_with_index do |pr, i|
            
              name = pr['name'][locale] || pr['name'][contrary_locale]
              bio = pr['bio'][locale] || pr['bio'][contrary_locale] if pr['bio']
              affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']
              
              presenter = conference.presenters.find_or_create_by_locale_and_name locale, name
              presenter.code ||= "#{event.code}:#{i + 1}"
              presenter.gravatar = pr['gravatar']
              presenter.bio ||= bio
              presenter.affiliation = affiliation
              presenter.save if presenter.changed?
              event.presenters << presenter unless event.presenters.include? presenter
              
            end if ev['presenters']            

            ev['sub_events'].each_with_index do |sev, i|
              parse_sub_event event, sev, i + 1, locale
            end if ev['sub_events']
            
            index = index + 1
          end
        end
        
      end
    end
    
  end
  
  # JRubyKaigi 2011のLTのパース
  def self.parse_sub_event parent, sev, index, locale
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    code = "#{parent.code}:#{index}"
    sub_event = parent.sub_events.find_or_create_by_code_and_locale  code, locale
p sub_event
    sub_event.kind = 'session'
    sub_event.title = sev['title'][locale] || sev['title'][contrary_locale]
    sub_event.abstract = sev['abstract'] ? sev['abstract'][locale] || sev['abstract'][contrary_locale] : nil
    sub_event.start_at = parent.start_at
    sub_event.end_at = parent.end_at
    sub_event.room = parent.room
    sub_event.language = sev['language']
    sub_event.position = index
    sub_event.save if sub_event.changed?

    sev['presenters'].each_with_index do |pr, i|
    
      name = pr['name'][locale] || pr['name'][contrary_locale]
      bio = pr['bio'][locale] || pr['bio'][contrary_locale] if pr['bio']
      affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']
      
      presenter = parent.conference.presenters.find_or_create_by_locale_and_name locale, name
      presenter.code ||= "#{sub_event.code}:#{i + 1}"
      presenter.gravatar = pr['gravatar']
      presenter.bio ||= bio
      presenter.affiliation = affiliation
      presenter.save if presenter.changed?
      sub_event.presenters << presenter unless sub_event.presenters.include? presenter
      
    end if sev['presenters']
    
    sub_event
  end
  
end
