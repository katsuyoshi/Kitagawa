# -*- coding: utf-8 -*-
require 'open-uri'

class Conference < ActiveRecord::Base
  has_many :days
  has_many :rooms
  has_many :events
  has_many :presenters

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
  
  def self.jrubykaigi2011
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

end
