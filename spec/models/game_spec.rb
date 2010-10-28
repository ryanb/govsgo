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

  it "should report moves after a position index" do
    @game.moves = "aa-bb-cc-dd"
    @game.moves_after(2).should == "cc-dd"
  end

  it "should report no moves when nil" do
    @game.moves_after(2).should == ""
  end

  it "should report no moves when out of range" do
    @game.moves = "aa-bb-cc-dd"
    @game.moves_after(8).should == ""
  end

  it "should set creator to black or white when choosing that color" do
    user = Factory(:user)
    @game.creator = user
    @game.chosen_color.should be_nil
    @game.chosen_color = "black"
    @game.prepare
    @game.black_player.should == user
    @game.chosen_color.should == "black"
    @game.current_player.should == user
    @game.black_player = nil
    @game.chosen_color = "white"
    @game.prepare
    @game.white_player.should == user
    @game.chosen_color.should == "white"
  end

  it "should raise an OutOfTurn exception when attempting to play when it's not your turn" do
    user = Factory(:user)
    @game.save!
    lambda { @game.move("aa", user) }.should raise_error(GameEngine::OutOfTurn)
    @game.update_attribute(:current_player_id, user.id)
    lambda { @game.move("bb", user) }.should_not raise_error(GameEngine::OutOfTurn)
  end

  it "should generate profile for black" do
    user = Factory(:user)
    game = Factory(:game, :current_player => user, :black_player => user, :handicap => 4, :black_score => 3)
    profile = game.profile_for(:black)
    profile.handicap_or_komi.should == "4 handicap"
    profile.score.should == 3
    profile.user.should == user
    profile.current.should be_true
    profile.last_status.should be_blank
  end

  it "should generate profile for white as GNU Go" do
    game = Factory(:game, :komi => 6.5, :white_player_id => nil, :white_score => 4, :current_player_id => Factory(:user).id, :moves => "PASS")
    profile = game.profile_for(:white)
    profile.handicap_or_komi.should == "6.5 komi"
    profile.score.should == 4
    profile.captured.should == 4
    profile.user.should be_nil
    profile.current.should be_false
    profile.last_status.should == "passed"
  end

  it "should have resigned as last status in profile" do
    game = Factory(:game, :white_player => Factory(:user), :moves => "RESIGN")
    game.profile_for(:white).last_status.should == "resigned"
  end

  it "should return SGF format for normal play" do
    game = Factory(:game, :moves => "aa-bbcc-PASS-dd", :handicap => 0, :board_size => 9, :komi => 6.5, :finished_at => Time.now, :white_score => 30.5, :black_score => 0)
    game.black_player.username = "foo"
    game.black_player.rank = "4k"
    game.white_player.username = ""
    game.white_player.rank = ""
    sgf = game.sgf
    sgf.should include("(;FF[4]GM[1]CA[utf-8]AP[govsgo:0.1]RU[Japanese]SZ[9]KM[6.5]HA[0]")
    sgf.should include("PB[foo]BR[4k]PW[Guest]WR[]")
    sgf.should include("RE[W+30.5]")
    sgf.should include(";B[aa];W[bb];B[];W[dd])")
  end

  it "should return SGF format for handicap game" do
    game = Factory(:game, :moves => "aa-RESIGN", :handicap => 2, :board_size => 19, :white_player => nil, :black_score => 0, :white_score => 1, :finished_at => Time.now)
    sgf = game.sgf
    sgf.should include("RE[W+R]")
    sgf.should include("HA[2]AB[pd][dp]")
    sgf.should include(";W[aa])")
  end

  it "should determine capture count from score when game hasn't ended" do
    game = Factory(:game, :black_score => 2, :white_score => 3)
    game.captured(:black).should == 2
    game.captured(:white).should == 3
  end

  it "should determine capture count from moves when game has ended" do
    game = Factory(:game, :moves => "aa-bb-PASS-ccdd-ffgghh-RESIGN", :finished_at => Time.now)
    game.captured(:black).should == 2
    game.captured(:white).should == 1
  end

  it "should determine capture count from moves when game with handicap has ended" do
    game = Factory(:game, :moves => "aa-bb-PASS-ccdd-ffgghh-RESIGN", :finished_at => Time.now, :handicap => 2)
    game.captured(:black).should == 1
    game.captured(:white).should == 2
  end
end
