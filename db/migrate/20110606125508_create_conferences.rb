# -*- coding: utf-8 -*-
class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.string :code
      t.string :title_ja
      t.string :title_en

      t.timestamps
    end
    Conference.create :code => 'RubyKaigi2011', :title_en => 'RubyKaigi 2011', :title_ja => '日本Ruby会議2011'
  end

  def self.down
    drop_table :conferences
  end
end
