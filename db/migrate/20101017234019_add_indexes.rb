class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :authentications, :user_id
    add_index :games, :black_player_id
    add_index :games, :white_player_id
    add_index :games, :current_player_id
    add_index :games, [:id, :current_player_id, :finished_at]
  end

  def self.down
    remove_index :authentications, :user_id
    remove_index :games, :black_player_id
    remove_index :games, :white_player_id
    remove_index :games, :current_player_id
    remove_index :games, :column => [:id, :current_player_id, :finished_at]
  end
end
