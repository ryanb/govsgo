module GamesHelper
  def color_at(vertex, game = @game)
    if    game.black_positions_list.include? vertex then "b"
    elsif game.white_positions_list.include? vertex then "w"
    else                                                 "e"
    end
  end
end
