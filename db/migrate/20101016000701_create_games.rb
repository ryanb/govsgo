class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :black_player_id
      t.integer :white_player_id
      t.integer :current_player_id
      t.float :black_score
      t.float :white_score
      t.text :black_positions
      t.text :white_positions
      t.text :moves
      t.text :valid_positions
      t.float :komi
      t.integer :handicap
      t.integer :board_size
      t.datetime :last_move_at
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
