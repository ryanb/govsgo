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

  it "black level is 10 when even" do
    game = Factory.build(:game, :handicap => 0, :komi => 6.5)
    game.level_for(game.black_player).should == 10
  end

  it "black level is 1 when 9 handicap and 6.5 komi" do
    game = Factory.build(:game, :handicap => 9, :komi => 6.5)
    game.level_for(game.black_player).should == 1
  end

  it "black level is 9 when 0.5 komi" do
    game = Factory.build(:game, :handicap => 0, :komi => 0.5)
    game.level_for(game.black_player).should == 9
  end

  it "white level is 11 when even" do
    game = Factory.build(:game, :handicap => 0, :komi => 6.5)
    game.level_for(game.white_player).should == 11
  end

  it "white level is 20 when 9 handicap and 6.5 komi" do
    game = Factory.build(:game, :handicap => 9, :komi => 6.5)
    game.level_for(game.white_player).should == 20
  end

  it "is even with black when setting level to 10" do
    game = Factory.build(:game)
    game.adjust_to_level(10)
    game.chosen_color.should == "black"
    game.handicap.should == 0
    game.komi.should == 6.5
  end

  it "chooses black with 9 handicap and 6.5 komi when setting level to 1" do
    game = Factory.build(:game)
    game.adjust_to_level(1)
    game.chosen_color.should == "black"
    game.handicap.should == 9
    game.komi.should == 6.5
  end

  it "chooses black with 0 handicap and 0.5 komi when setting level to 9" do
    game = Factory.build(:game)
    game.adjust_to_level(9)
    game.chosen_color.should == "black"
    game.handicap.should == 0
    game.komi.should == 0.5
  end

  it "is even with white when setting level to 11" do
    game = Factory.build(:game)
    game.adjust_to_level(11)
    game.chosen_color.should == "white"
    game.handicap.should == 0
    game.komi.should == 6.5
  end

  it "chooses white with 7 handicap and 6.5 komi when setting level to 18" do
    game = Factory.build(:game)
    game.adjust_to_level(18)
    game.chosen_color.should == "white"
    game.handicap.should == 7
    game.komi.should == 6.5
  end

  it "chooses white with 0 handicap and 0.5 komi when setting level to 12" do
    game = Factory.build(:game)
    game.adjust_to_level(12)
    game.chosen_color.should == "white"
    game.handicap.should == 0
    game.komi.should == 0.5
  end

  it "resulting level should be minus one for loss and plus one for win" do
    game = Factory.build(:game, :black_score => 0, :white_score => 1, :finished_at => Time.now, :handicap => 0, :komi => 6.5)
    game.level_for(game.black_player).should == 10
    game.resulting_level_for(game.black_player).should == 9
    game.level_for(game.white_player).should == 11
    game.resulting_level_for(game.white_player).should == 12
  end

  it "should be an active game when started and not finished" do
    Factory.build(:game, :started_at => Time.now, :finished_at => nil).should be_active
    Factory.build(:game, :started_at => nil, :finished_at => nil).should_not be_active
    Factory.build(:game, :started_at => nil, :finished_at => Time.now).should_not be_active
    Factory.build(:game, :started_at => Time.now, :finished_at => Time.now).should_not be_active
  end

  it "should know other player is opponent" do
    game = Factory.build(:game)
    game.opponent(game.black_player).should == game.white_player
  end

  it "should have nil winner/loser for game which hasn't started" do
    game = Factory.build(:game, :started_at => nil, :finished_at => Time.now)
    game.winner.should be_nil
    game.loser.should be_nil
  end

  it "should know if a user is a player in a game" do
    game = Factory.build(:game)
    game.should be_player(game.black_player)
    game.should be_player(game.white_player)
    game.should_not be_player(Factory.build(:user))
  end
end
