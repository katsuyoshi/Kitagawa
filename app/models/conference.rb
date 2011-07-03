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

end
