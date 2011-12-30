class MovesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @moves = @game.moves_after(params[:after].to_i)
  end

  def create
    @game = Game.find(params[:game_id])
    @game.move(params[:move], current_user)
    @game.queue_computer_move
    Notifications.move(@game).deliver if @game.current_player && @game.current_player.email.present? && @game.current_player.email_on_move?
  rescue GameEngine::IllegalMove
    flash[:alert] = t("illegal_move", :scope => "controllers.moves")
  rescue GameEngine::OutOfTurn
    flash[:alert] = t("out_of_turn", :scope => "controllers.moves")
  end
end
