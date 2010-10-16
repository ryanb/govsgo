class MovesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @game.move(params[:move])
    @game.save!
  end
end
