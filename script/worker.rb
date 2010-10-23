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

require "mysql2"
require "go/gtp"
require "oily_png"

require File.join(RAILS_ROOT, *%w[lib game_thumb])
require File.join(RAILS_ROOT, *%w[lib game_engine])

config = open(CONFIG_PATH) { |file|
  Hash[YAML.load(file)[RAILS_ENV].map { |k, v| [k.to_sym, v] }]
}
mysql  = Mysql2::Client.new(config)

job "Game.move" do |args|
  id = args["id"]
  game = mysql.query("select * from games where id='#{id}' limit 1", :symbolize_keys => true).first
  update = {}
  GameEngine.run(:board_size => game[:board_size].to_i, :handicap => game[:handicap].to_i, :komi => game[:komi].to_f) do |engine|
    engine.replay(game[:moves])
    update[:moves] = [game[:moves].to_s, engine.move(args["current_color"])].reject(&:empty?).join("-")
    update[:last_move_at] = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    update[:current_player_id] = args["next_player_id"]
    update[:black_positions] = engine.positions(:black)
    update[:white_positions] = engine.positions(:white)
    if engine.over?
      update[:finished_at] = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
      update[:black_score] = engine.black_score
      update[:white_score] = engine.white_score
    else
      update[:black_score] = engine.captures(:black)
      update[:white_score] = engine.captures(:white)
    end
  end
  values = update.map { |col, val| "#{col}='#{mysql.escape(val.to_s)}'" }.join(", ")
  mysql.query("UPDATE games SET #{values} WHERE id=#{id} AND current_player_id IS NULL AND finished_at IS NULL")
  GameThumb.generate(id, game[:board_size], update[:black_positions], update[:white_positions])
end
