class Message < ActiveRecord::Base
  attr_accessible :game_id, :content, :move_index
  belongs_to :game
  belongs_to :user

  validate :user_playing_game
  validates_presence_of :user_id, :game_id, :content

  def user_playing_game
    if game && !game.player?(user)
      errors.add :game_id, "is not owned by you so you cannot send the message."
    end
  end
end
