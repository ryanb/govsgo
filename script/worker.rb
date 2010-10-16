require "mysql2"
require "go/gtp"

def gnugo_to_sgf(vertices, boardsize)
  if vertices.is_a? Array
    vertices.map { |v| gnugo_to_sgf(v, boardsize) }.join
  else
    Go::GTP::Point.new(vertices, board_size: boardsize).to_sgf
  end
end

def finish_game(final_score)
  if final_score =~ /\A([BW])\+(\d+\.\d+)\z/
    results                                          =
      {finished_at: Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")}
    results[$1 == 'B' ? :black_score : :white_score] = $2.to_f
    results[$1 == 'B' ? :white_score : :black_score] = 0
    results
  else
    raise "Unrecognized score format:  #{final_score}"
  end
end

RAILS_ENV   = ENV.fetch("RAILS_ENV", "development")
CONFIG_PATH = File.join(File.dirname(__FILE__), *%w[.. config database.yml])

config      = open(CONFIG_PATH) { |file|
  Hash[YAML.load(file)[RAILS_ENV].map { |k, v| [k.to_sym, v] }]
}
mysql       = Mysql2::Client.new(config)

job "Game.move" do |args|
  Go::GTP.run_gnugo do |gtp|
    boardsize  = args["boardsize"].to_i
    color      = args["current_color"]
    next_color = color == "black" ? "white" : "black"
    moves      = args["moves_for_db"]
    
    gtp.boardsize      boardsize         if boardsize
    gtp.fixed_handicap args["handicap"]  if args["handicap"].to_i.nonzero?
    gtp.komi           args["komi"]      if args["komi"]
    gtp.replay(args["moves_for_gnugo"], args["first_color"])
    computers_move = gtp.genmove(color)

    sql_update = { valid_positions:   gnugo_to_sgf( gtp.all_legal(next_color),
                                                    boardsize ),
                   black_positions:   gnugo_to_sgf( gtp.list_stones(:black),
                                                    boardsize ),
                   white_positions:   gnugo_to_sgf( gtp.list_stones(:white),
                                                    boardsize ),
                   current_player_id: args["next_player_id"] }
    if computers_move.to_s.upcase == "RESIGN"
      sql_update.merge!(finish_game(gtp.final_score))
    elsif computers_move.to_s.upcase == "PASS" and moves =~ /-\z/
      sql_update[:moves] = "#{moves}-"
      sql_update.merge!(finish_game(gtp.final_score))
    else
      computers_move           = computers_move.to_s.upcase == "PASS" ?
                                 ""                                   :
                                 gnugo_to_sgf(computers_move, boardsize)
      sql_update[:moves]       = [moves, computers_move].compact.join("-")
      sql_update[:black_score] = gtp.captures(:black)
      sql_update[:white_score] = gtp.captures(:white)
    end
    mysql.query(
      "UPDATE games SET "                                             +
      sql_update.map { |col, val| "%s = %p" % [col, val] }.join(", ") +
      " WHERE id = #{args['id']} AND current_player_id IS NULL"
    )
  end
end
