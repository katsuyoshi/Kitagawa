# -*- coding: utf-8 -*-
require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "prepare_room shoud have 4 records" do
    Room.prepare_rooms
    
    assert_equal 2, Room.ja.all.size
    r = Room.ja.all[0]
    assert_equal 'M', r.code
    assert_equal 'ja', r.locale
    assert_equal '大ホール', r.name
    assert_equal 1, r.position
    r = Room.ja.all[1]
    assert_equal 'S', r.code
    assert_equal 'ja', r.locale
    assert_equal '小ホール', r.name
    assert_equal 2, r.position
    
    assert_equal 2, Room.en.all.size
    r = Room.en.all[0]
    assert_equal 'M', r.code
    assert_equal 'en', r.locale
    assert_equal 'Main Hall', r.name
    assert_equal 1, r.position
    r = Room.en.all[1]
    assert_equal 'S', r.code
    assert_equal 'en', r.locale
    assert_equal 'Sub Hall', r.name
    assert_equal 2, r.position

  end
end
