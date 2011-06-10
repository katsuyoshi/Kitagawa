# -*- coding: utf-8 -*-
require 'open-uri'

class Conference < ActiveRecord::Base
  has_many :days
  has_many :rooms
  has_many :events

  def self.all_conferences_hash_for_json
    {
      :ja => {
        :conferences => self.all.map{|c| c.hash_for_json_with_locale 'ja'}
      },
      :en => {
        :conferences => self.all.map{|c| c.hash_for_json_with_locale 'en'}
      }
    }
  end

  def hash_for_json_with_locale locale
    {
      :conference => {
        :code => self.code,
        :title => locale == 'ja' ? self.title_ja : self.title_en,
        :days => self.days.map {|d| d.hash_for_json_with_locale(locale)}
      },
    }
  end
  
  def create_room_if_needs code, locale, name, position
    r = self.rooms.find_or_create_by_code_and_locale code, locale
    r.name ||= name
    r.position ||= position
    r.save if r.changed?
  end

  def self.rubykaigi2011
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
  
private
  def self.parse_rubykaigi2011_with_locale_and_timetalbes locale, timetables 
    conference = self.rubykaigi2011
           
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


end
