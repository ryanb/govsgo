class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :game_id
      t.integer :user_id
      t.text :content
      t.integer :move_index
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
