class AddPrivateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :private, :boolean, :default => false, :null => false
  end

  def self.down
    add_column :users, :private
  end
end
