class MovesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @moves = @game.moves_after(params[:after].to_i)
  end

  def create
    @game = Game.find(params[:game_id])
    @game.move(params[:move], current_user)
    @game.queue_computer_move
    Notifications.move(@game).deliver if @game.current_player && @game.current_player.email.present? && @game.current_player.email_on_move? && !@game.current_player.online?
  rescue GameEngine::IllegalMove
    flash[:alert] = "That is an illegal move."
  rescue GameEngine::OutOfTurn
    flash[:alert] = "It is not your turn to move."
  end
end
