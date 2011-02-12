class Message < ActiveRecord::Base
  attr_accessible :game_id, :content, :move_index
  belongs_to :game
  belongs_to :user

  validate :ensure_player
  validates_presence_of :user_id, :game_id, :content

  before_create :remember_move_index

  def ensure_player
    if game && !game.player?(user)
      errors.add :game_id, "is not owned by you so you cannot send the message."
    end
  end

  def remember_move_index
    self.move_index = game.split_moves.size-1 if game && game.moves.present?
  end

  def send_email?
    recipient && recipient.email_on_message?
  end

  def recipient
    game && game.opponent(user)
  end
end
