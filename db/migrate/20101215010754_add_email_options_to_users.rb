class AddEmailOptionsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_on_invitation, :boolean, :default => false, :null => false
    add_column :users, :email_on_move, :boolean, :default => false, :null => false
    add_column :users, :unsubscribe_token, :string
  end

  def self.down
    remove_column :users, :unsubscribe_token
    remove_column :users, :email_on_move
    remove_column :users, :email_on_invitation
  end
end
