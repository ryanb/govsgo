class AddGuestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :guest, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :guest
  end
end
