class MovesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @moves = @game.moves_after(params[:after].to_i)
  end
  
  def create
    @game = Game.find(params[:game_id])
    if current_user == @game.current_player and
       @game.valid_positions_list.include?(params[:move])
      @game.move(params[:move])
      @game.save!
    else
      head 409
    end
  end
end
