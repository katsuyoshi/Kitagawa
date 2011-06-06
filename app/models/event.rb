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
  

end
