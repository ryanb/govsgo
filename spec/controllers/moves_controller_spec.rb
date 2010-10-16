require 'spec_helper'

describe MovesController do
  it "should add a move and respond with javascript" do
    game = Game.create!
    post "create", :game_id => game.id, :format => "js"
    response.should be_success
  end
end
