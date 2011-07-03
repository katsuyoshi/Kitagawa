# --*-- coding:utf-8 --*--
require 'test_helper'

class PresenterTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "to_json should get " do
    p = Presenter.create :name => 'Katsuyoshi', :bio => 'I like SUSHI.', :affiliation => 'ITO SOFT DESIGN Inc.', :locale => 'en'
    expected = "{\"presenter\":{\"code\":null,\"name\":\"Katsuyoshi\",\"gravatar\":null,\"affiliation\":\"ITO SOFT DESIGN Inc.\",\"bio\":\"I like SUSHI.\",\"locale\":\"en\"}}"
    assert_equal expected, p.to_json
  end
end
