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
  
  it "should be able to convert a move capture list for GNU Go" do
    @game.board_size = 19
    @game.moves      = "acbbccdd-ad"
    @game.moves_for_gnugo.should eq(%w[A17 A16])
  end
  
  it "should invoke GNU Go with game arguments" do
    @game.board_size = 13
    Go::GTP.expects(:run_gnugo).with(arguments: "--boardsize 13")
    @game.gnugo { }
  end
  
  it "should allow for multiple arguments" do
    @game.board_size = 9
    @game.handicap   = 2
    @game.komi       = 6.5
    Go::GTP.expects(:run_gnugo).with do |args|
      args.include?(:arguments)             and
      args[:arguments] =~ /--boardsize 9\b/ and
      args[:arguments] =~ /--handicap 2\b/  and
      args[:arguments] =~ /--komi 6\.5\b/
    end
    @game.gnugo { }
  end
  
  it "should replay moves when connecting to GNU Go" do
    @game.board_size = 19
    @game.moves      = "ac-ad"
    Go::GTP.expects(:run_gnugo).yields(gtp = mock)
    gtp.expects(:replay).with(%w[A17 A16])
    @game.gnugo { }
  end
  
  it "should report moves after a position index" do
    @game.moves = "aa-bb-cc-dd"
    @game.moves_after(2).should == "cc-dd"
  end
  
  it "should set creator to black or white when choosing that color" do
    user = Factory(:user)
    @game.creator = user
    @game.chosen_color.should be_nil
    @game.chosen_color = "black"
    @game.black_player.should == user
    @game.chosen_color.should == "black"
    @game.black_player = nil
    @game.chosen_color = "white"
    @game.white_player.should == user
    @game.chosen_color.should == "white"
  end
end
