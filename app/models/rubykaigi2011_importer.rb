# -*- coding: utf-8 -*-
require 'importer'

class Rubykaigi2011Importer < Importer

  # RubyKaigi 2011のインポート
  def self.import
    self.import_from_json_file 'http://rubykaigi.org/2011/schedule/all.json'
  end
  
  # RubyKaigi 2011のインポート
  def self.import_from_json_file path
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
    parse_timetalbes 'ja', timetables
    parse_timetalbes 'en', timetables    
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
  
  def self.conference
    code = 'rubykaigi2011'
    conference = Conference.find_by_code code
    if conference.nil?
      conference = Conference.create
      conference.code = code
      conference.title_ja ||= '日本Ruby会議2011'
      conference.title_en ||= 'RubyKaigi 2011'
      if conference.changed?
        conference.save
      end
      conference.create_room_if_needs 'M', 'ja', '大ホール', 1
      conference.create_room_if_needs 'M', 'en', 'Main Hall', 1
      conference.create_room_if_needs 'S', 'ja', '小ホール', 2
      conference.create_room_if_needs 'S', 'en', 'Sub Hall', 2
    end
    conference
  end

private

  # RubyKaigi 2011のJSONデータのバース
  def self.parse_timetalbes locale, timetables 
    conference = self.conference
           
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
              
              presenter = Presenter.find_or_create_by_locale_and_name locale, name
              presenter.code ||= "#{event.code}:#{i + 1}"
              # 上書きで更新する
              presenter.gravatar = pr['gravatar']
              presenter.bio = bio
              presenter.affiliation = affiliation
              presenter.save if presenter.changed?
              event.presenters << presenter unless event.presenters.include? presenter
            end if ev['presenters']
            
            ev['sub_events'].each_with_index do |sev, i|
              sub_event = parse_sub_event_of_event event, locale, sev
              sub_event.position = i + 1
              sub_event.save if sub_event.changed?
            end if ev['sub_events']
            
            index = index + 1
          end
        end
        
      end
    end
    
  end

  # RubyKaigi 2011のLTデータのバース
  def self.parse_sub_event_of_event parent, locale, sub_event_info
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    h = {}
    
    code = sub_event_info['_id']
    sub_event = parent.sub_events.find_or_create_by_code_and_locale(code, locale)
    sub_event.kind = 'session'
    sub_event.title = sub_event_info['title'][locale] || sub_event_info['title'][contrary_locale]
    sub_event.abstract = sub_event_info['abstract'][locale] || sub_event_info['abstract'][contrary_locale] if sub_event_info['abstract']
    sub_event.abstract = nil if sub_event.abstract == "#TODO"
    sub_event.room = parent.room
    sub_event.start_at = parent.start_at
    sub_event.end_at = parent.end_at
    sub_event.save if sub_event.changed?

    sub_event_info['presenters'].each_with_index do |pr, i|
            
      name = pr['name'][locale] || pr['name'][contrary_locale]
      bio = pr['bio'][locale] || pr['bio'][contrary_locale] if pr['bio']
      affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']
              
      presenter = Presenter.find_or_create_by_locale_and_name locale, name
      presenter.code ||= "#{sub_event.code}:#{i + 1}"
      # サプイベントは未設定の場合のみ設定する
      presenter.gravatar ||= pr['gravatar']
      presenter.bio ||= bio
      presenter.bio = nil if presenter.bio == "#TODO"
      presenter.affiliation = affiliation
      presenter.save if presenter.changed?
      sub_event.presenters << presenter unless sub_event.presenters.include? presenter
              
    end if sub_event_info['presenters']
    sub_event
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
  
end
