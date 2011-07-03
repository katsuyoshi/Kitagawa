# -*- coding: utf-8 -*-
class Jrubykaigi2011Importer < Importer

  # JRubyKaigi 2011の記録のインポート
  # db/jrubykaigi2011.yml から設定
  def self.import
    yaml = load_yaml_file_with_key File.join(Rails.root, 'db/jrubykaigi2011.yml'), 'jrubykaigi2011'
    if yaml
      conference = self.conference
      parse_conference_with_locale_and_timetable conference, 'ja', yaml['timetable']
      parse_conference_with_locale_and_timetable conference, 'en', yaml['timetable']
    end
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
  
private
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
