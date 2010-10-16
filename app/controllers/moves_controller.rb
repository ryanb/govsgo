class MovesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    # create move here...
  end
end
