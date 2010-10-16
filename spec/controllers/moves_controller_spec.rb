require 'spec_helper'

describe MovesController do
  it "should show moves in game" do
    game = Game.create!(board_size: 19, moves: "aa-bb-cc")
    post "index", :game_id => game.id, :format => "js", :after => 1
    response.body.should include("\"bb-cc\"")
  end

  it "should add a move and respond with javascript" do
    game = Game.create!(board_size: 19)
    post "create", :game_id => game.id, :format => "js", :move => "aa"
    response.should be_success
  end
end
