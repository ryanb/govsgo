class AddEmailOnMessageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_on_message, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :email_on_message
  end
end
