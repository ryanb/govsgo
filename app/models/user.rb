class User < ActiveRecord::Base
  attr_accessible :username, :email, :password, :password_confirmation, :guest

  has_many :authentications

  attr_accessor :password
  before_save :prepare_password

  validates_presence_of :username, :unless => :guest?
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :allow_blank => true
  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true

  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  def games
    Game.where("black_player_id = ? or white_player_id = ?", id, id)
  end

  def other_games
    Game.where("(black_player_id != ? or black_player_id is null) and (white_player_id != ? or white_player_id is null)", id, id)
  end

  def games_my_turn
    games.active.where("current_player_id = ?", id)
  end

  def games_their_turn
    games.active.where("current_player_id != ? or current_player_id is null", id)
  end

  def password_required?
    !guest? && (new_record? || password_hash.blank?) && authentications.empty?
  end

  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    self.username = omniauth['user_info']['nickname'] if username.blank?
  end

  def online?
    last_request_at && last_request_at > 5.minutes.ago
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
end
