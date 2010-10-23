class RemoveValidPositionsFromGames < ActiveRecord::Migration
  def self.up
    remove_column :games, :valid_positions
  end

  def self.down
    add_column :games, :valid_positions, :text
  end
end
