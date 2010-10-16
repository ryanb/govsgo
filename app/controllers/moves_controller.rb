class MovesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @game.move(params[:move])
    begin
      @game.save!
    rescue
      p @game.moves
      raise
    end
  end
end
