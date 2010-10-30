class AddAvatarUrlToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_url, :string
  end

  def self.down
    remove_column :users, :avatar_url
  end
end
