class AddPublicizedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :publicized_at, :datetime
  end

  def self.down
    remove_column :users, :publicized_at
  end
end
