class MovesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @moves = @game.moves_after(params[:after].to_i)
  end
  
  def create
    @game = Game.find(params[:game_id])
    @game.move(params[:move])
    @game.save!
  end
end
