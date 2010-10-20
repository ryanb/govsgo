########################################
### PID Management and Daemonization ###
########################################

RAILS_ENV  = ENV.fetch("RAILS_ENV", "development")
RAILS_ROOT = File.join(File.dirname(__FILE__), "..")
SCRIPT_DIR = File.join(RAILS_ROOT, "script")
PID_FILE   = File.join(RAILS_ROOT, *%W[tmp pids #{ENV['WORKER_NAME']}.pid])

def authorize(&block)
  open(PID_FILE, File::CREAT | File::EXCL | File::WRONLY) do |pid|
    pid.flock(File::LOCK_EX)
    if block.nil? or block.call  # allows for daemonization
      pid.puts Process.pid
    else
      pid.flock(File::LOCK_UN)
      revoke  # remove this file if anything went wrong
      return false
    end
    pid.flock(File::LOCK_UN)
  end

  at_exit do
    revoke
  end
  true
rescue Errno::EEXIST  # pid_file already exists
  open(PID_FILE, "r+") do |pid|
    if pid.flock(File::LOCK_EX | File::LOCK_NB)
      if pid.read =~ /\A(\d+)/
        begin
          Process.kill(0, $1.to_i)  # check for the existing process
        rescue Errno::ESRCH         # no such process
          # stale PID file found, clearing it and reloading
          if revoke
            pid.flock(File::LOCK_UN)  # release the lock before we recurse
            return authorize(&block)  # try again
          end
        rescue Errno::EACCES  # don't have permission
          # nothing we can do so give up
        end
      end
      pid.flock(File::LOCK_UN)  # release the lock
    else
      # couldn't grab a file lock to verify existing PID file
      return false
    end
  end
  # process was already running
  false
end

def revoke
  File.unlink(PID_FILE)
  true
rescue Exception
  false
end

def daemonize
  exit!(0) if fork
  Process.setsid
  exit!(0) if fork
  Dir.chroot("/")
  File.umask(0000)
  $stdin.reopen("/dev/null")
  true
rescue Exception # if anything goes wrong
  false
end

unless authorize { RAILS_ENV == "development" or daemonize }
  abort "Computer player is already running or failed to daemonize"
end

############
### Jobs ###
############

CONFIG_PATH = File.join(RAILS_ROOT, *%w[config database.yml])
THUMB_LIB   = File.join(RAILS_ROOT, *%w[lib game_thumb])

require "mysql2"
require "go/gtp"
require "oily_png"

require THUMB_LIB

def gnugo_to_sgf(vertices, boardsize)
  if vertices.is_a? Array
    vertices.map { |v| gnugo_to_sgf(v, boardsize) }.join
  else
    Go::GTP::Point.new(vertices, :board_size => boardsize).to_sgf
  end
end

def sgf_to_indices(sgf)
  sgf.to_s.scan(/[a-s]{2}/).map { |ln| Go::GTP::Point.new(ln).to_indices }
end

def finish_game(final_score)
  if final_score =~ /\A([BW])\+(\d+\.\d+)\z/
    results                                          =
      {:finished_at => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")}
    results[$1 == 'B' ? :black_score : :white_score] = $2.to_f
    results[$1 == 'B' ? :white_score : :black_score] = 0
    results
  else
    raise "Unrecognized score format:  #{final_score}"
  end
end

config = open(CONFIG_PATH) { |file|
  Hash[YAML.load(file)[RAILS_ENV].map { |k, v| [k.to_sym, v] }]
}
mysql  = Mysql2::Client.new(config)

job "Game.move" do |args|
  Go::GTP.run_gnugo do |gtp|
    id         = args["id"]
    boardsize  = args["boardsize"].to_i
    color      = args["current_color"]
    next_color = color == "black" ? "white" : "black"
    moves      = args["moves_for_db"]

    gtp.boardsize      boardsize         if boardsize
    gtp.fixed_handicap args["handicap"]  if args["handicap"].to_i.nonzero?
    gtp.komi           args["komi"]      if args["komi"]
    gtp.replay(args["moves_for_gnugo"], args["first_color"])
    other_stones   = gtp.list_stones(next_color)
    computers_move = gtp.genmove(color)
    captured       = other_stones - gtp.list_stones(next_color)

    sql_update = { :valid_positions =>   gnugo_to_sgf( gtp.all_legal(next_color),
                                                    boardsize ),
                   :black_positions =>   gnugo_to_sgf( gtp.list_stones(:black),
                                                    boardsize ),
                   :white_positions =>   gnugo_to_sgf( gtp.list_stones(:white),
                                                    boardsize ),
                   :current_player_id => args["next_player_id"] }
    if computers_move.to_s.upcase == "RESIGN"
      sql_update.merge!(finish_game(gtp.final_score))
    elsif computers_move.to_s.upcase == "PASS" and moves =~ /-\z/
      sql_update[:moves] = "#{moves}-"
      sql_update.merge!(finish_game(gtp.final_score))
    else
      computers_move           = computers_move.to_s.upcase == "PASS" ?
                                 ""                                   :
                                 gnugo_to_sgf( [computers_move] + captured,
                                               boardsize )
      sql_update[:moves]       = [moves, computers_move].compact.join("-")
      sql_update[:black_score] = gtp.captures(:black)
      sql_update[:white_score] = gtp.captures(:white)
    end
    mysql.query(
      "UPDATE games SET "                                             +
      sql_update.map { |col, val| "%s = %p" % [col, val] }.join(", ") +
      " WHERE id = #{id} AND current_player_id IS NULL AND "          +
      "finished_at IS NULL"
    )
    GameThumb.generate( id,
                        boardsize,
                        sgf_to_indices(sql_update[:black_positions]),
                        sgf_to_indices(sql_update[:white_positions]) )
  end
end
