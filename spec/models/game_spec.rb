require File.dirname(__FILE__) + '/../spec_helper'

describe Game do
  before :each do
    @game = Game.new
  end
  
  it "should require a valid board_size" do
    @game.board_size = 50
    @game.should have(1).error_on(:board_size)
    @game.board_size = 9
    @game.should have(:no).errors_on(:board_size)
  end
  
  it "should require a valid handicap" do
    @game.handicap = 50
    @game.should have(1).error_on(:handicap)
    @game.handicap = 2
    @game.should have(:no).errors_on(:handicap)
  end
  
  it "should require a valid komi" do
    @game.komi = -3
    @game.should have(1).error_on(:komi)
    @game.komi = 6.5
    @game.should have(:no).errors_on(:komi)
  end
  
  it "should require that moves be a valid list of moves and captures" do
    @game.moves = "wrong"
    @game.should have(1).error_on(:moves)
    @game.moves = "acbbccdd-ad"
    @game.should have(:no).errors_on(:moves)
  end
  
  it "should indicate a human player when black_player_id is set" do
    @game.should_not be_black_player_is_human
    @game.black_player_id = 1
    @game.should be_black_player_is_human
  end
  
  it "should indicate a human player when white_player_id is set" do
    @game.should_not be_white_player_is_human
    @game.white_player_id = 1
    @game.should be_white_player_is_human
  end
  
  it "should report moves after a position index" do
    @game.moves = "aa-bb-cc-dd"
    @game.moves_after(2).should == "cc-dd"
  end
  
  it "should report no moves when nil" do
    @game.moves_after(2).should be_nil
  end
  
  it "should set creator to black or white when choosing that color" do
    user = Factory(:user)
    @game.creator = user
    @game.chosen_color.should be_nil
    @game.chosen_color = "black"
    @game.black_player.should == user
    @game.chosen_color.should == "black"
    @game.current_player.should == user
    @game.black_player = nil
    @game.chosen_color = "white"
    @game.white_player.should == user
    @game.chosen_color.should == "white"
  end
end
