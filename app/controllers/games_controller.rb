class GamesController < ApplicationController
  before_filter :login_required, :only => [:my, :edit, :update]
  before_filter :fetch_games, :only => [:index, :show, :other, :my, :new]

  def index
    @other_games_limit = @my_games.blank? ? 8 : 4
    @other_games = @other_games.paginate(:page => 1, :per_page => @other_games_limit)
    @my_games = @my_games.paginate(:page => 1, :per_page => 4) if @my_games
  end

  def show
    @game = Game.find(params[:id])
    @other_games = @other_games.paginate(:page => 1, :per_page => 5)
    @my_games = @my_games.paginate(:page => 1, :per_page => 5) if @my_games
    @profiles = @game.profiles
    @profiles.reverse! if current_user && @profiles.first.user == current_user
  end

  def new
    @game = Game.new
    if params[:username]
      @game.chosen_opponent = "user"
      @game.opponent_username = params[:username]
    else
      @game.chosen_opponent = "gnugo"
      @game.chosen_color = "black"
      @game.adjust_difficulty = true
    end
    @game.komi = params[:komi] || 6.5
    @game.handicap = params[:handicap] || 0
    @game.board_size = params[:board_size] || 19
    @other_games = @other_games.paginate(:page => 1, :per_page => 5)
    @my_games = @my_games.paginate(:page => 1, :per_page => 5) if @my_games
  end

  def create
    @game = Game.new
    @game.creator = current_user_or_guest
    @game.attributes = params[:game]
    @game.prepare
    if @game.save
      @game.queue_computer_move
      flash[:notice] = "Game started. Click on a point below to place your stone."
      redirect_to @game
    else
      fetch_games
      @other_games = @other_games.paginate(:page => 1, :per_page => 5)
      @my_games = @my_games.paginate(:page => 1, :per_page => 5) if @my_games
      render :action => 'new'
    end
  end

  def edit
    
  end

  def update
    @game = Game.find(params[:id])
    raise "Unable to update game because you are not the current player" if @game.current_player != current_user
    raise "Unable to update game because it has already started." if @game.started?
    if params[:invitation_button] == "Accept"
      @game.start
      @game.save!
    elsif params[:invitation_button] == "Decline"
      @game.update_attribute(:finished_at, Time.now)
    else
      @game.switch_current_player
      @game.update_attributes!(params[:game])
    end
  end

  def other
    @other_games = @other_games.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def my
    @my_games = @my_games.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def resources
  end

  def sgf
    @game = Game.find(params[:id])
    render :text => @game.sgf, :content_type => 'application/x-go-sgf'
  end

  private

  def fetch_games
    if logged_in?
      @my_games = current_user.games.recent
      @other_games = current_user.other_games.recent
    else
      @other_games = Game.recent
    end
  end
end
