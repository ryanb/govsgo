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

  it "should know if a given user is a player" do
    user = Factory(:user)
    @game.should_not be_player(nil)
    @game.should_not be_player(user)
    @game.white_player = user
    @game.should be_player(user)
  end

  it "should report white and black player usernames and GNU Go when nil" do
    user = Factory(:user)
    Factory.build(:game, :black_player => user).black_player_name.should == user.username
    Factory.build(:game, :white_player => user).white_player_name.should == user.username
    Game.new.white_player_name.should == "GNU Go"
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
    profile.user.should be_nil
    profile.current.should be_false
    profile.last_status.should == "passed"
  end

  it "should have resigned as last status in profile" do
    game = Factory(:game, :white_player => Factory(:user), :moves => "RESIGN")
    game.profile_for(:white).last_status.should == "resigned"
  end
end
