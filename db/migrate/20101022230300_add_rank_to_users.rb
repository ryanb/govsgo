class AddRankToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :rank, :string
  end

  def self.down
    remove_column :users, :rank
  end
end
