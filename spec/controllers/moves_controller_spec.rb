require 'spec_helper'

describe MovesController do
  fixtures :all
  render_views

  it "should show moves in game" do
    game = Factory(:game, :moves => "aa-bb-cc")
    get "index", :game_id => game.id, :format => "js", :after => 1
    response.body.should include("\"bb-cc\"")
  end

  it "should add a move and respond with javascript" do
    game = Factory(:game)
    session[:user_id] = game.current_player.id
    post "create", :game_id => game.id, :format => "js", :move => "aa"
    response.should be_success
  end
end
