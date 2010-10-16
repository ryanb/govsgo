require File.dirname(__FILE__) + '/../spec_helper'

describe Game do
  it "should be valid" do
    Game.new.should be_valid
  end
end
