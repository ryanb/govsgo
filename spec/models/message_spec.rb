require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  it "should validate that the user is a player in a game" do
    game = Factory(:game)
    Factory.build(:message, :game => game, :user => game.black_player).should be_valid
    Factory.build(:message, :game => game, :user => Factory(:user)).should have(1).error_on(:game_id)
  end

  it "should validate the presence of game, user and content" do
    message = Factory.build(:message, :game_id => "", :user_id => "", :content => "")
    message.should have(1).error_on(:game_id)
    message.should have(1).error_on(:user_id)
    message.should have(1).error_on(:content)
  end

  it "should set the move index to the last move position" do
    game = Factory(:game, :moves => "aa-bb-cc")
    Factory(:message, :game => game).move_index.should == 2
    Factory(:message).move_index.should be_nil
  end
end
