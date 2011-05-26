require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => Game.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "new action should redirect user to signin when trying to challenge username" do
    get :new, :username => "foo"
    response.should redirect_to(signin_url)
  end

  it "create action should render new template when model is invalid" do
    Game.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Game.any_instance.expects(:queue_computer_move)
    Game.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(game_url(assigns[:game]))
  end

  it "sgf action should return SGF data" do
    Game.any_instance.stubs(:sgf).returns("sgf data")
    get :sgf, :id => Game.first
    response.content_type.should == "application/x-go-sgf"
    response.body.should == "sgf data"
  end
end

describe GamesController, "logged in" do
  fixtures :all
  render_views

  before(:each) do
    @user = Factory(:user)
    @controller.stubs(:current_user).returns(@user)
  end

  it "new action should render new template with custom username" do
    get :new, :username => "foo"
    response.should render_template(:new)
  end

  it "create action should send email to opponent user" do
    opponent = Factory(:user, :email_on_invitation => true)
    post :create, :game => { :chosen_opponent => "user", :opponent_username => opponent.username, :chosen_color => "black" }
    response.should redirect_to(game_url(assigns[:game]))
    Notifications.deliveries.size.should == 1
    Notifications.deliveries.first.subject.should == "[Go vs Go] Invitation from #{@user.username}"
  end

  it "create action should not send email to gnugo user" do
    post :create, :game => { :chosen_opponent => "gnugo", :opponent_username => '', :chosen_color => "black" }
    response.should redirect_to(game_url(assigns[:game]))
    Notifications.deliveries.size.should == 0
  end

  it "create action should not send email to opponent user when unwanted" do
    opponent = Factory(:user, :email_on_invitation => false)
    post :create, :game => { :chosen_opponent => "user", :opponent_username => opponent.username, :chosen_color => "black" }
    response.should redirect_to(game_url(assigns[:game]))
    Notifications.deliveries.size.should == 0
  end

  it "edit action should render edit javascript template and fill in user attributes" do
    game = Factory(:game, :white_player => @user, :current_player => @user)
    get :edit, :id => game, :format => :js
    response.should render_template(:edit)
    assigns(:game).chosen_opponent.should == "user"
    assigns(:game).opponent_username.should == game.black_player.username
    assigns(:game).chosen_color.should == "white"
  end

  it "update action should raise an error when already started" do
    lambda {
      put :update, :id => Factory(:game, :started_at => Time.now, :current_player => @user)
    }.should raise_error(RuntimeError)
  end

  it "update action should not allow user to update a game when he is not current player" do
    lambda {
      put :update, :id => Factory(:game, :started_at => nil, :current_player => nil)
    }.should raise_error(RuntimeError)
  end

  it "update action should mark game as started when accepting and adjust current player" do
    game = Factory(:game, :started_at => nil, :white_player => @user, :current_player => @user)
    put :update, :id => game, :invitation_button => "Accept", :format => :js
    game.reload.started_at.should_not be_nil
    game.current_player.should == game.black_player
  end

  it "update action should mark game as finished when declining" do
    game = Factory(:game, :started_at => nil, :white_player => @user, :current_player => @user)
    put :update, :id => game, :invitation_button => "Decline", :format => :js
    game.reload.started_at.should be_nil
    game.finished_at.should_not be_nil
  end

  it "update action should update game attributes" do
    game = Factory(:game, :started_at => nil, :white_player => @user, :current_player => @user, :board_size => 19)
    put :update, :id => game, :game => {:board_size => 9, :chosen_color => "white", :chosen_opponent => "user", :opponent_username => game.black_player.username}, :format => :js
    game.reload.started_at.should be_nil
    game.board_size.should == 9
    game.current_player.should == game.black_player
  end
end
