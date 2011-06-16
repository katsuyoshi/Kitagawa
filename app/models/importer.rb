# -*- coding: utf-8 -*-
require 'open-uri'

class Importer

  def self.import_rubykaigi2011_from_json_file path
    parser = nil
    open(path) do |f|
      last_data = DataFile.find_or_create_by_key('rubykaigi2011')
      context = f.read
      # 前回と同じなら更新しない
      if last_data.context == context
# DEBUGME:        return
      end
      last_data.context = context
      last_data.save
      parser = JSON.parser.new context
    end

    timetables = parser.parse['timetable']
    parse_rubykaigi2011_with_locale_and_timetalbes 'ja', timetables
    parse_rubykaigi2011_with_locale_and_timetalbes 'en', timetables    
  end
  
  def self.import_lightning_talks_of_rubykaigi2011
    yaml = YAML.load_file File.join(Rails.root, 'db/lightning_talks_of_rubykaigi2011.yml')
    parse_lightning_talks_of_rubykaigi2011_with_locale_and_events 'ja', yaml['events']
    parse_lightning_talks_of_rubykaigi2011_with_locale_and_events 'en', yaml['events']
  end
  
private
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
  
end
