# -*- coding: utf-8 -*-
class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.string :code
      t.string :title_ja
      t.string :title_en

      t.timestamps
    end
  end

  def self.down
    drop_table :conferences
  end
end
