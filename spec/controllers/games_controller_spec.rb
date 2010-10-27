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
