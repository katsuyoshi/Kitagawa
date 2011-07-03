require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase

  def setup
    @json_path = File.join(Rails.root, 'db', 'timetables.json')
  end
  
  # Replace this with your real tests.
  test "rubykaigi2011 should contains 2 rooms" do
    conference = Rubykaigi2011Importer.conference
    assert conference
    assert_equal 4, conference.rooms.size
    assert_equal 2, conference.rooms.find_all_by_locale('ja').size
    assert_equal 2, conference.rooms.find_all_by_locale('en').size
  end
  
  test "import_from_json_file should make all datas" do
    Rubykaigi2011Importer.import_from_json_file @json_path
    
    conference = Rubykaigi2011Importer.conference
    days = conference.days
    assert_equal 3, days.size
    assert_equal Date.parse('2011-7-16'), days[0].date
    assert_equal Date.parse('2011-7-17'), days[1].date
    assert_equal Date.parse('2011-7-18'), days[2].date
    
    # 2011-07-16テスト ja
    assert_equal %w(2011-07-16:M:open:1 16MOP 16M01 2011-07-16:M:lunch:1 2011-07-16:M:announcement:1 16M02 2011-07-16:M:break:1 16M03 16M04 2011-07-16:M:break:2 16M05 16M06 2011-07-16:M:break:3 16M07 16M08 2011-07-16:M:dinner:1 16MDN), days[0].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-16:S:open:1 2011-07-16:S:lunch:1 2011-07-16:S:break:1 16S01 16S02 2011-07-16:S:break:2 16S03 16S04 2011-07-16:S:break:3 16S05 16S06 2011-07-16:S:dinner:1), days[0].events.ja.sub.map {|e| e.code} 
    
    # 2011-07-17テスト ja
    assert_equal %w(2011-07-17:M:open:1 17M01 17M02 2011-07-17:M:break:1 17M03 17M04 2011-07-17:M:lunch:1 17M05 17M06 2011-07-17:M:break:2 17M07 17M08 2011-07-17:M:break:3 17M09 2011-07-17:M:break:4 17M10 2011-07-17:M:announcement:1 2011-07-17:M:transit_time:1 2011-07-17:M:party:1), days[1].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-17:S:open:1 17S01 17S02 2011-07-17:S:break:1 17S03 17S04 2011-07-17:S:lunch:1 17S05 17S06 2011-07-17:S:break:2 17S07 17S08 2011-07-17:S:break:3 2011-07-17:S:break:4 2011-07-17:S:transit_time:1 2011-07-17:S:party:1), days[1].events.ja.sub.map {|e| e.code} 
    
    # 2011-07-18テスト ja
    assert_equal %w(2011-07-18:M:open:1 18M01 18M02 2011-07-18:M:break:1 18M03 18M04 2011-07-18:M:lunch:1 18M05 18M06 2011-07-18:M:break:2 18M07 18M08 2011-07-18:M:break:3 18M09 2011-07-18:M:break:4 18M10 18MCL), days[2].events.ja.main.map {|e| e.code} 
    assert_equal %w(2011-07-18:S:open:1 18S01 18S02 2011-07-18:S:break:1 18S03 18S04 2011-07-18:S:lunch:1 18S05 18S06 2011-07-18:S:break:2 18S07 18S08 2011-07-18:S:break:3 2011-07-18:S:break:4), days[2].events.ja.sub.map {|e| e.code} 




    # 2011-07-16テスト en
    assert_equal %w(2011-07-16:M:open:1 16MOP 16M01 2011-07-16:M:lunch:1 2011-07-16:M:announcement:1 16M02 2011-07-16:M:break:1 16M03 16M04 2011-07-16:M:break:2 16M05 16M06 2011-07-16:M:break:3 16M07 16M08 2011-07-16:M:dinner:1 16MDN), days[0].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-16:S:open:1 2011-07-16:S:lunch:1 2011-07-16:S:break:1 16S01 16S02 2011-07-16:S:break:2 16S03 16S04 2011-07-16:S:break:3 16S05 16S06 2011-07-16:S:dinner:1), days[0].events.en.sub.map {|e| e.code} 
    
    # 2011-07-17テスト en
    assert_equal %w(2011-07-17:M:open:1 17M01 17M02 2011-07-17:M:break:1 17M03 17M04 2011-07-17:M:lunch:1 17M05 17M06 2011-07-17:M:break:2 17M07 17M08 2011-07-17:M:break:3 17M09 2011-07-17:M:break:4 17M10 2011-07-17:M:announcement:1 2011-07-17:M:transit_time:1 2011-07-17:M:party:1), days[1].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-17:S:open:1 17S01 17S02 2011-07-17:S:break:1 17S03 17S04 2011-07-17:S:lunch:1 17S05 17S06 2011-07-17:S:break:2 17S07 17S08 2011-07-17:S:break:3 2011-07-17:S:break:4 2011-07-17:S:transit_time:1 2011-07-17:S:party:1), days[1].events.en.sub.map {|e| e.code} 

    # 2011-07-18テスト en
    assert_equal %w(2011-07-18:M:open:1 18M01 18M02 2011-07-18:M:break:1 18M03 18M04 2011-07-18:M:lunch:1 18M05 18M06 2011-07-18:M:break:2 18M07 18M08 2011-07-18:M:break:3 18M09 2011-07-18:M:break:4 18M10 18MCL), days[2].events.en.main.map {|e| e.code} 
    assert_equal %w(2011-07-18:S:open:1 18S01 18S02 2011-07-18:S:break:1 18S03 18S04 2011-07-18:S:lunch:1 18S05 18S06 2011-07-18:S:break:2 18S07 18S08 2011-07-18:S:break:3 2011-07-18:S:break:4), days[2].events.en.sub.map {|e| e.code} 

#p Presenter.all.map{|p| p.name}

  end
  
  test "import_from_json_file should not change datas when it was called second time" do
    Rubykaigi2011Importer.import_from_json_file @json_path
    assert_difference("Rubykaigi2011Importer.conference.events.size", 0) do
      assert_difference("Presenter.all.size", 0) do
        Rubykaigi2011Importer.import_from_json_file @json_path
      end
    end
  end
  
  test "import_from_json_file should have a person by ja and en" do
    Rubykaigi2011Importer.import_from_json_file @json_path
    
    presenters = Presenter.find_all_by_code "16M01:1"
    assert_equal 2, presenters.size
    
    en_presenter = presenters.find{|p| p.locale == "en"}
    assert en_presenter
    assert_equal "Aaron Patterson (tenderlove)", en_presenter.name
    
    ja_presenter = presenters.find{|p| p.locale == "ja"}
    assert ja_presenter
    assert_equal "Aaron Patterson (tenderlove)", ja_presenter.name
  end
  
  
end
