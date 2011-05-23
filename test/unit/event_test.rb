require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    Room.prepare_rooms
    @json_path = File.join(Rails.root, 'db', 'timetables.json')
  end
  
  test "import_from_json_file should make all datas" do
    Event.import_from_json_file @json_path
    
    days = Day.all
    assert_equal 3, days.size
    assert_equal Date.parse('2011-7-16'), days[0].date
    assert_equal Date.parse('2011-7-17'), days[1].date
    assert_equal Date.parse('2011-7-18'), days[2].date
    
    # 2011-07-16�e�X�g ja
    assert_equal %w(2011-07-16:M:open:1 16MOP 16M01 2011-07-16:M:lunch:1 2011-07-16:M:announcement:1 16M02 2011-07-16:M:break:1 16M03 16M04 2011-07-16:M:break:2 16M05 16M06 2011-07-16:M:break:3 16M07 16M08 2011-07-16:M:dinner:1 16MDN), days[0].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-16:S:open:1 2011-07-16:S:lunch:1 2011-07-16:S:break:1 16S01 16S02 2011-07-16:S:break:2 16S03 16S04 2011-07-16:S:break:3 16S05 16S06 2011-07-16:S:dinner:1), days[0].events.ja.sub.map {|e| e.code} 
    
    # 2011-07-17�e�X�g ja
    assert_equal %w(2011-07-17:M:open:1 17M01 17M02 2011-07-17:M:break:1 17M03 17M04 2011-07-17:M:lunch:1 17M05 17M06 2011-07-17:M:break:2 17M07 17M08 2011-07-17:M:break:3 17M09 2011-07-17:M:break:4 17M10 2011-07-17:M:announcement:1 2011-07-17:M:transit_time:1 2011-07-17:M:party:1), days[1].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-17:S:open:1 17S01 17S02 2011-07-17:S:break:1 17S03 17S04 2011-07-17:S:lunch:1 17S05 17S06 2011-07-17:S:break:2 17S07 17S08 2011-07-17:S:break:3 2011-07-17:S:break:4 2011-07-17:S:transit_time:1 2011-07-17:S:party:1), days[1].events.ja.sub.map {|e| e.code} 
    
    # 2011-07-18�e�X�g ja
    assert_equal %w(2011-07-18:M:open:1 18M01 18M02 2011-07-18:M:break:1 18M03 18M04 2011-07-18:M:lunch:1 18M05 18M06 2011-07-18:M:break:2 18M07 18M08 2011-07-18:M:break:3 18M09 2011-07-18:M:break:4 18M10 18MCL), days[2].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-18:S:open:1 18S01 18S02 2011-07-18:S:break:1 18S03 18S04 2011-07-18:S:lunch:1 18S05 18S06 2011-07-18:S:break:2 18S07 18S08 2011-07-18:S:break:3 2011-07-18:S:break:4), days[2].events.ja.sub.map {|e| e.code} 




    # 2011-07-16�e�X�g en
    assert_equal %w(2011-07-16:M:open:1 16MOP 16M01 2011-07-16:M:lunch:1 2011-07-16:M:announcement:1 16M02 2011-07-16:M:break:1 16M03 16M04 2011-07-16:M:break:2 16M05 16M06 2011-07-16:M:break:3 16M07 16M08 2011-07-16:M:dinner:1 16MDN), days[0].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-16:S:open:1 2011-07-16:S:lunch:1 2011-07-16:S:break:1 16S01 16S02 2011-07-16:S:break:2 16S03 16S04 2011-07-16:S:break:3 16S05 16S06 2011-07-16:S:dinner:1), days[0].events.en.sub.map {|e| e.code} 
    
    # 2011-07-17�e�X�g en
    assert_equal %w(2011-07-17:M:open:1 17M01 17M02 2011-07-17:M:break:1 17M03 17M04 2011-07-17:M:lunch:1 17M05 17M06 2011-07-17:M:break:2 17M07 17M08 2011-07-17:M:break:3 17M09 2011-07-17:M:break:4 17M10 2011-07-17:M:announcement:1 2011-07-17:M:transit_time:1 2011-07-17:M:party:1), days[1].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-17:S:open:1 17S01 17S02 2011-07-17:S:break:1 17S03 17S04 2011-07-17:S:lunch:1 17S05 17S06 2011-07-17:S:break:2 17S07 17S08 2011-07-17:S:break:3 2011-07-17:S:break:4 2011-07-17:S:transit_time:1 2011-07-17:S:party:1), days[1].events.en.sub.map {|e| e.code} 

    # 2011-07-18�e�X�g en
    assert_equal %w(2011-07-18:M:open:1 18M01 18M02 2011-07-18:M:break:1 18M03 18M04 2011-07-18:M:lunch:1 18M05 18M06 2011-07-18:M:break:2 18M07 18M08 2011-07-18:M:break:3 18M09 2011-07-18:M:break:4 18M10 18MCL), days[2].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-18:S:open:1 18S01 18S02 2011-07-18:S:break:1 18S03 18S04 2011-07-18:S:lunch:1 18S05 18S06 2011-07-18:S:break:2 18S07 18S08 2011-07-18:S:break:3 2011-07-18:S:break:4), days[2].events.en.sub.map {|e| e.code} 

#p Presenter.all.map{|p| p.name}
p Affiliation.all.map{|a| a.title}

  end
  
  test "import_from_json_file should stay data when it was called second time" do
    Event.import_from_json_file @json_path
    Event.import_from_json_file @json_path
    
    assert_equal 1, Event.find_by_locale_and_code('ja', '16M01').presenters.size
    assert_equal 1, Event.find_by_locale_and_code('ja', '16M01').presenters[0].affiliations.size
  end
  
end