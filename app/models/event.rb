# --*-- coding: utf-8 --*--
class Event < ActiveRecord::Base
  belongs_to :day
  belongs_to :room
  has_many :event_presenters
  has_many :presenters, :through => :event_presenters

  scope :ja, where(:locale => 'ja')
  scope :en, where(:locale => 'en')
  scope :main, joins(:room).where('rooms.code' => 'M')
  scope :sub, joins(:room).where('rooms.code' => 'S')

  default_scope order('start_at, position')

  def self.import_from_json_file path
    parser = JSON.parser.new File.read(path)
    timetables = parser.parse['timetable']
    parse_with_locale_and_timetalbes 'ja', timetables
    parse_with_locale_and_timetalbes 'en', timetables    
  end
  
private
  def self.parse_with_locale_and_timetalbes locale, timetables
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
            
            ev['presenters'].each do |pr|
            
              presenter = Presenter.find_or_create_by_locale_and_name locale, pr['name'][locale] || pr['name'][contrary_locale]
              presenter.bio ||= pr['bio'][locale] || pr['bio'][contrary_locale]
              presenter.affiliation = pr['affiliation'][locale] || pr['affiliation'][contrary_locale] if pr['affiliation']              
              event.presenters << presenter unless event.presenters.include? presenter
              
            end if ev['presenters']
            
            index = index + 1
          end
        end
        
      end
    end
  end


end
