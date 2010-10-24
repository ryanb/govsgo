module GamesHelper
  THUMB_DIR = Rails.root + "public" + "assets" + "games" + "thumbs"

  def color_at(position, game = @game)
    if    game.black_positions_list.include? position then "b"
    elsif game.white_positions_list.include? position then "w"
    else                                                 "e"
    end
  end

  def thumbnail(game)
    thumb = THUMB_DIR + "#{game.id}.png"
    path  = thumb.exist? ? thumb.to_s.sub(/\A.*\bpublic\b/, "") :
                           "thumbnail/#{game.board_size}/board.png"
    image_tag(path, :size => "80x80")
  end

  def link_to_game_thumbnail(game)
    link_to thumbnail(game), game, :class => "thumbnail"
  end

  def game_score(score, finished)
    if finished
      if score.to_f == 1.0
        "won"
      elsif score.to_f > 0
        "won by #{score}"
      end
    else
      pluralize(score.to_i, "captured stone")
    end
  end

  def board_div(game, &block)
    options = {
      "id" => "board",
      "class" => "size_#{game.board_size}",
      "data-moves" => game.moves,
      "data-handicap" => game.handicap.to_i,
      "data-current-player" => game.current_player_id.to_i,
      "data-current-user" => current_user.try(:id),
      "data-finished" => game.finished?,
    }
    content_tag(:div, options, &block)
  end
end
