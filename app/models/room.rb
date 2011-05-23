# -*- coding: utf-8 -*-
class Room < ActiveRecord::Base
  belongs_to :day
  
  has_many :events

  def self.create_if_needs code, locale, name, position
    r = Room.find_or_create_by_code_and_locale code, locale
    r.name ||= name
    r.position ||= position
    r.save if r.changed?
  end
    
  def self.prepare_rooms
    create_if_needs 'M', 'ja', '大ホール', 1
    create_if_needs 'M', 'en', 'Main Hall', 1
    create_if_needs 'S', 'ja', '小ホール', 2
    create_if_needs 'S', 'en', 'Sub Hall', 2
  end
  
  scope :ja, where(:locale => 'ja')
  scope :en, where(:locale => 'en')
  
  default_scope order('position')
  
end
