# -*- coding:utf-8 -*-
require 'test_helper'

class EventTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def setup
    @json_path = File.join(Rails.root, 'db', 'timetables.json')
  end
  
  test "to_json" do
    Rubykaigi2011Importer.import_from_json_file @json_path
    expected = "{\"event\":{\"code\":\"16M01\",\"kind\":\"session\",\"title\":\"Ruby Ruined My Life.\",\"abstract\":\"For the final RubyKaigi, we will discuss how Ruby changes can people's\\nlives for the better and sometimes for worse.  The life stories\\ninvolved will be used as a catalyst for looking at new features and\\nproblems in Ruby and Rails, as well as ideas for where Ruby should go\\nfor continued success.\",\"start_at\":\"2011-07-16T01:30:00Z\",\"end_at\":\"2011-07-16T03:00:00Z\",\"room\":{\"code\":\"M\",\"name\":\"\\u5927\\u30db\\u30fc\\u30eb\"},\"language\":\"\",\"locale\":\"ja\",\"position\":3,\"presenters\":[{\"presenter\":{\"code\":\"16M01:1\",\"name\":\"Aaron Patterson (tenderlove)\",\"gravatar\":null,\"affiliation\":\"AT&T Interactive\",\"bio\":\"When he isn\\u2019t ruining people\\u2019s lives by writing software like phuby,\\nenterprise, and neversaydie, Aaron can be found writing slightly more\\nuseful software like nokogiri. To keep up his Gameboy Lifestyle, Aaron\\nspends his weekdays writing high quality software for ATTi. Be sure to\\ncatch him on Karaoke night, where you can watch him sing his favorite\\nsmooth rock hits of the 70\\u2019s and early 80\\u2019s.\",\"locale\":\"ja\"}}],\"sub_events\":[],\"archives\":[]}}"
    assert_equal expected, Event.find_by_locale_and_code('ja', '16M01').to_json
  end
  
  test "sub events should contain sub events" do
    parent = Event.create :title => 'parent'
    child1 = Event.create :title => 'sub event 1'
    child2 = Event.create :title => 'sub event 2'
    
    parent.save
    parent.sub_events << child1
    parent.sub_events << child2
    
    assert_equal 2, parent.sub_events.size
    assert_equal parent, child1.parent_event
    assert_equal parent, child2.parent_event
  end
  
end
