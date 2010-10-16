class Game < ActiveRecord::Base
  attr_accessible :black_player_id, :white_player_id, :current_player_id, :black_score, :white_score, :black_positions, :white_positions, :moves, :valid_positions, :komi, :handicap, :board_size, :last_move_at, :started_at, :finished_at
end
