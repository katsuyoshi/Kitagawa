# -*- coding: utf-8 -*-
require 'open-uri'

class Event < ActiveRecord::Base
  belongs_to :day
  belongs_to :room
  belongs_to :conference
  has_many :event_presenters
  has_many :presenters, :through => :event_presenters
  has_many :sub_events, :class_name => 'Event', :foreign_key => 'parent_event_id'
  belongs_to :parent_event, :class_name => 'Event', :foreign_key => 'parent_event_id'

  scope :ja, where(:locale => 'ja')
  scope :en, where(:locale => 'en')
  scope :main, joins(:room).where('rooms.code' => 'M')
  scope :sub, joins(:room).where('rooms.code' => 'S')
  scope :locale, lambda {|l|
    where('locale = ?', l)
  }

  default_scope order('start_at, position')

  def self.import_from_json_file path
    parser = nil
    open(path) do |f|
      last_data = DataFile.find_or_create_by_key('timetables')
      context = f.read
      # 前回と同じなら更新しない
      if last_data.context == context
        return
      end
      last_data.context = context
      last_data.save
      parser = JSON.parser.new context
    end

    # 削除されたデータを消すために、JSONに含まれるデータを保持する
    @imported_event_ids = []
    @imported_presenter_ids = []

    timetables = parser.parse['timetable']
    parse_with_locale_and_timetalbes 'ja', timetables
    parse_with_locale_and_timetalbes 'en', timetables    
  end
  
  def hash_for_json
    {
      :event => {
        :code => self.code,
        :kind => self.kind,
        :title => self.title,
        :abstract => self.abstract,
        :start_at => self.start_at,
        :end_at => self.end_at,
        :room => self.room.hash_for_json,
        :language => self.language,
        :locale => self.locale,
        :position => self.position,
        :presenters => self.presenters.map {|p| p.hash_for_json},
        :sub_events => self.sub_events.map {|e| e.hash_for_json}
      }
    }
  end
  
  def to_json
    hash_for_json.to_json
  end
  
  def self.all_for_json
    {
      :ja => Day.all.map {|d| d.hash_for_json_with_locale('ja')},
      :en => Day.all.map {|d| d.hash_for_json_with_locale('en')}
    }
  end
  
  def self.all_to_json
    all_for_json.to_json
  end
  
private
  def self.parse_with_locale_and_timetalbes locale, timetables
    Room.prepare_rooms
        
    contrary_locale = locale == 'ja' ? 'en' : 'ja'
    days = timetables.keys.sort
    days.each do |d|
    
      day = Day.find_or_create_by_date Date.parse(d)
      timetables[d].each do |e|
        room = Room.find_by_locale_and_code locale, e['room_id']
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
            
            event = Event.find_or_create_by_locale_and_code locale, code
            @imported_event_ids << event.id
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
              @imported_presenter_ids << presenter.id
              presenter.code ||= "#{event.code}:#{i + 1}"
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
    
=begin 手入力の物も削除する可能性があるので保留
    # 削除された物を削除
    Event.find(:all, :conditions => ['id not in (?)', @imported_event_ids]).each {|d| d.destroy }
    Presenter.find(:all, :conditions => ['id not in (?)', @imported_presenter_ids]).each {|d| d.destroy }
=end
    
  end


end
