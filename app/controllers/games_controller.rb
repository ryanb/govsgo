class GamesController < ApplicationController
  def index
    @games = Game.recent.limit(8)
  end
  
  def show
    @game = Game.find(params[:id])
  end
  
  def new
    @game = Game.new
    if params[:username]
      @game.chosen_opponent   = "user"
      @game.opponent_username = params[:username]
    else
      @game.chosen_opponent = "gnugo"
      @game.chosen_color    = "black"
    end
    @game.komi       = params[:komi]       || 6.5
    @game.handicap   = params[:handicap]   || 0
    @game.board_size = params[:board_size] || 19
  end
  
  def create
    @game            = Game.new
    @game.creator    = current_user_or_guest
    @game.attributes = params[:game]
    @game.prepare
    if @game.save
      @game.queue_computer_move
      flash[:notice] = "Successfully created game."
      redirect_to @game
    else
      render :action => 'new'
    end
  end
end
