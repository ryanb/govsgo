require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Game.new.valid?
  end
end
