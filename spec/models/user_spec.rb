require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    User.delete_all
  end

  it "should be valid" do
    Factory.build(:user).should be_valid
  end

  it "guest should be valid when empty" do
    User.new(:guest => true).should have(0).errors
  end

  it "guest should require password when updating" do
    user = User.create!(:guest => true)
    user.guest = false
    user.should have(1).error_on(:password)
  end

  it "should not require password when using other forms of authentication" do
    user = Factory(:user, :guest => true, :password => nil)
    user.authentications.create!(:provider => "foo", :uid => 123)
    user.guest = false
    user.should have(0).errors_on(:password)
  end

  it "should require username" do
    Factory.build(:user, :username => '').should have(1).error_on(:username)
  end

  it "should require password" do
    Factory.build(:user, :password => '').should have(1).error_on(:password)
  end

  it "should require well formed email" do
    Factory.build(:user, :email => 'foo@bar@example.com').should have(1).error_on(:email)
  end

  it "should validate uniqueness of email" do
    Factory(:user, :email => 'bar@example.com')
    Factory.build(:user, :email => 'bar@example.com').should have(1).error_on(:email)
  end

  it "should validate uniqueness of username" do
    Factory(:user, :username => 'uniquename')
    Factory.build(:user, :username => 'uniquename').should have(1).error_on(:username)
  end

  it "should not allow odd characters in username" do
    Factory.build(:user, :username => 'odd ^&(@)').should have(1).error_on(:username)
  end

  it "should validate password is longer than 3 characters" do
    Factory.build(:user, :password => 'bad').should have(1).error_on(:password)
  end

  it "should require matching password confirmation" do
    Factory.build(:user, :password_confirmation => 'nonmatching').should have(1).error_on(:password)
  end

  it "should generate password hash and salt on create" do
    user = Factory(:user)
    user.password_hash.should_not be_nil
    user.password_salt.should_not be_nil
  end

  it "should authenticate by username" do
    user = Factory(:user, :username => 'foobar', :password => 'secret')
    User.authenticate('foobar', 'secret').should == user
  end

  it "should authenticate by email" do
    user = Factory(:user, :email => 'foo@bar.com', :password => 'secret')
    User.authenticate('foo@bar.com', 'secret').should == user
  end

  it "should not authenticate bad username" do
    User.authenticate('nonexisting', 'secret').should be_nil
  end

  it "should not authenticate bad password" do
    Factory(:user, :username => 'foobar', :password => 'secret').save!
    User.authenticate('foobar', 'badpassword').should be_nil
  end

  it "should have games based on white or black" do
    user = Factory(:user)
    black_game = Factory(:game, :black_player => user)
    white_game = Factory(:game, :white_player => user)
    user.games.should == [black_game, white_game]
  end

  it "should separate games for my turn vs their turn" do
    user = Factory(:user)
    black_game = Factory(:game, :black_player => user, :current_player => user)
    white_game = Factory(:game, :white_player => user, :current_player => nil)
    Factory(:game, :black_player => user, :current_player => user, :finished_at => Time.now)
    Factory(:game, :white_player => user, :finished_at => Time.now)
    user.games_my_turn.should == [black_game]
    user.games_their_turn.should == [white_game]
  end

  it "should filter other games" do
    Game.delete_all
    user = Factory(:user)
    black_game = Factory(:game, :black_player => user)
    white_game = Factory(:game, :white_player => user)
    other_game = Factory(:game)
    user.other_games.should == [other_game]
  end

  it "should report user online when last request time within 5 minutes" do
    Factory.build(:user, :last_request_at => 4.minutes.ago).should be_online
    Factory.build(:user, :last_request_at => 6.minutes.ago).should_not be_online
    Factory.build(:user).should_not be_online
  end

  it "should update black, white, and current player id when moving games" do
    user = Factory(:user)
    game = Factory(:game, :black_player => user, :white_player => user)
    other_user = Factory(:user)
    user.move_games_to(other_user)
    game.reload.black_player.should == other_user
    game.black_player.should == other_user
    game.current_player.should == other_user
  end

  it "should generate a unique 16 digit token for each user" do
    User.create!(:guest => true).token.should_not == User.create!(:guest => true).token
    User.create!(:guest => true).token.length.should == 16
  end

  it "gnugo_level defaults to 6" do
    User.new.gnugo_level.should == 6
  end

  it "gnugo_level should average out resulting level for past games" do
    user = Factory(:user)
    Factory(:game, :black_player => user, :white_player => nil, :finished_at => Time.now, :black_score => 1, :white_score => 0, :handicap => 9, :komi => 6.5) # resulting level 2
    Factory(:game, :black_player => user, :white_player => nil, :finished_at => Time.now, :black_score => 0, :white_score => 1, :handicap => 5, :komi => 6.5) # resulting level 4
    Factory(:game, :black_player => user, :white_player => nil, :finished_at => Time.now, :black_score => 1, :white_score => 0, :handicap => 5, :komi => 6.5) # resulting level 6
    Factory(:game, :black_player => user, :white_player => nil, :finished_at => 2.days.ago, :black_score => 1, :white_score => 0, :handicap => 0, :komi => 6.5) # ignore since older
    Factory(:game, :black_player => user, :white_player => nil, :handicap => 5, :komi => 6.5) # ignore since not finished
    Factory(:game, :black_player => user, :handicap => 4, :komi => 6.5) # ignore since not against GNU Go
    user.gnugo_level.should == 4
  end
end
