class Game < ActiveRecord::Base
  #################
  ### Callbacks ###
  #################

  after_save :update_thumbnail

  ####################
  ### Associations ###
  ####################

  belongs_to :black_player,   :class_name => "User"
  belongs_to :white_player,   :class_name => "User"
  belongs_to :current_player, :class_name => "User"

  ###################
  ### Validations ###
  ###################

  validates_inclusion_of :board_size, :in => [9, 13, 19],     :allow_nil => true
  validates_inclusion_of :handicap,   :in => (0..9).to_a,     :allow_nil => true
  validates_inclusion_of :komi,       :in => [0.5, 5.5, 6.5], :allow_nil => true
  validate               :opponent_found

  def opponent_found
    if chosen_opponent == "user" && (black_player.blank? || white_player.blank?)
      errors.add(:opponent_username, "not found")
    end
  end
  private :opponent_found

  attr_accessible :komi, :handicap, :board_size, :chosen_color, :chosen_opponent, :opponent_username

  ##############
  ### Scopes ###
  ##############

  scope :finished, where("finished_at is not null")
  scope :active,   where("finished_at is null")
  scope :recent,   order("updated_at desc")

  ########################
  ### Instance Methods ###
  ########################

  attr_accessor :chosen_color, :creator, :chosen_opponent, :opponent_username
  attr_writer   :position_changed

  def position_changed?
    @position_changed
  end

  def black_player_is_human?
    not black_player_id.blank?
  end

  def white_player_is_human?
    not white_player_id.blank?
  end

  def current_player_is_human?
    not current_player_id.blank?
  end

  def player?(user)
    user && (white_player == user || black_player == user)
  end

  def black_positions_list
    if black_positions && @black_positions_list && @black_positions_list.size != black_positions.size / 2
      @black_positions_list = nil
    end
    @black_positions_list ||= black_positions.to_s.scan(/[a-s]{2}/)
  end

  def white_positions_list
    if white_positions && @white_positions_list && @white_positions_list.size != white_positions.size / 2
      @white_positions_list = nil
    end
    @white_positions_list ||= white_positions.to_s.scan(/[a-s]{2}/)
  end

  def prepare
    opponent = nil
    if chosen_opponent == "user"
      opponent = User.find_by_username(opponent_username)
    end
    color = chosen_color.blank? ? %w[black white].sample : chosen_color
    case color
    when "black"
      self.black_player = creator
      self.white_player = opponent
    when "white"
      self.black_player = opponent
      self.white_player = creator
    end
    game_engine do |engine|
      if handicap.to_i.nonzero?
        self.black_positions = engine.positions(:black)
        self.current_player = white_player
      else
        self.current_player = black_player
      end
    end
    self.position_changed = true
  end

  def move(vertex, user)
    raise GameEngine::OutOfTurn if user.id != current_player_id
    game_engine do |engine|
      engine.replay(moves)
      self.moves = [moves, engine.move(current_color, vertex)].reject(&:blank?).join("-")
      self.black_positions = engine.positions(:black)
      self.white_positions = engine.positions(:white)
      self.current_player = next_player
      if engine.game_finished?
        self.finished_at = Time.now
        self.black_score = engine.black_score
        self.white_score = engine.white_score
      else
        self.black_score = engine.captures(:black)
        self.white_score = engine.captures(:white)
        self.position_changed = true
      end
    end
    # Check current_player again, fetching from database to async double move problem
    # This should probably be moved into a database lock so no updates happen between here and the save
    raise GameEngine::OutOfTurn if user.id != Game.find(id, :select => "current_player_id").current_player_id
    save!
  end

  def queue_computer_move
    unless current_player_is_human?
      Stalker.enqueue("Game.move", :id => id, :next_player_id => next_player.id, :current_color => current_color)
    end
  end

  def moves_after(index)
    (moves.to_s.split('-')[index..-1] || []).join('-')
  end

  def last_move
    (moves.to_s.split("-").last || "")[/\A[a-s]{2}/]
  end

  def current_color
    current_player == black_player ? :black : :white
  end

  def next_color
    current_player == black_player ? :white : :black
  end

  def next_player
    current_player == black_player ? white_player : black_player
  end

  def finished?
    not finished_at.blank?
  end

  def black_player_name
    profile_for(:black).name
  end

  def white_player_name
    profile_for(:white).name
  end

  def update_thumbnail
    if Rails.env != "test" && position_changed?
      GameThumb.generate(id, board_size, black_positions, white_positions)
    end
  end

  def profile_for(color)
    Profile.new(color).tap do |profile|
      if color.to_sym == :white
        profile.handicap_or_komi = "#{komi} komi"
      else
        profile.handicap_or_komi = "#{handicap} handicap"
      end
      if color.to_sym == :white
        profile.handicap_or_komi = "#{komi} komi"
      else
        profile.handicap_or_komi = "#{handicap} handicap"
      end
      profile.score = send("#{color}_score")
      profile.user = send("#{color}_player")
      if profile.user != current_player
        case moves.to_s.split("-").last
        when "PASS" then profile.last_status = "passed"
        when "RESIGN" then profile.last_status = "resigned"
        end
      end
    end
  end

  def profiles
    [profile_for(:white), profile_for(:black)]
  end

  private

  def game_engine
    GameEngine.run(:board_size => board_size, :handicap => handicap, :komi => komi) do |engine|
      yield engine
    end
  end
end
