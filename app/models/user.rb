class User < ActiveRecord::Base
  attr_accessible :username, :email, :password, :password_confirmation, :guest, :rank, :email_on_invitation, :email_on_move, :email_on_message, :time_zone, :locale

  has_many :authentications
  has_many :messages

  attr_accessor :password
  before_save :prepare_password
  before_create :generate_tokens

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

  def games_your_turn
    games.unfinished.where("current_player_id = ?", id)
  end

  def games_their_turn
    games.unfinished.where("current_player_id != ? or current_player_id is null", id)
  end

  def password_required?
    !guest? && (new_record? || password_hash.blank?) && authentications.empty?
  end

  def apply_omniauth(omniauth)
    if email.blank?
      self.email = omniauth['user_info']['email']
      self.email_on_invitation = true unless email.blank?
    end
    self.username = omniauth['user_info']['nickname'] if username.blank?
    self.avatar_url = omniauth['user_info']['image'] if omniauth['user_info'] && omniauth['user_info']['image'].present?
  end

  def online?
    last_request_at && last_request_at > 5.minutes.ago
  end

  def name_with_rank
    [username, rank].reject(&:blank?).join(" ")
  end

  def move_games_to(user)
    games.each do |game|
      %w[black white current].each do |type|
        game.update_attribute("#{type}_player_id", user.id) if game.send("#{type}_player_id") == id
      end
    end
  end

  def generate_tokens
    generate_token(:token)
    generate_token(:unsubscribe_token)
  end

  def generate_token(name)
    if self[name].blank?
      characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('1'..'9').to_a
      begin
        self[name] = Array.new(16) { characters.sample }.join
      end while self.class.exists?(name => token)
    end
  end

  def gnugo_level
    @gnugo_level ||= calculate_gnugo_level
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

  def calculate_gnugo_level
    finished_games = games.finished.with_gnugo
    if finished_games.size > 0
      levels = finished_games.order("finished_at desc").limit(3).map { |g| g.resulting_level_for(self) }
      level = (levels.inject(:+).to_f / levels.size).round
      [[level, 20].min, 1].max
    else
      6
    end
  end
end
