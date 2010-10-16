class Game < ActiveRecord::Base
  ####################
  ### Associations ###
  ####################
  
  belongs_to :black_player,   :class_name => "User"
  belongs_to :white_player,   :class_name => "User"
  belongs_to :current_player, :class_name => "User"
  
  ###################
  ### Validations ###
  ###################
  
  validates_inclusion_of :board_size, in: [9, 13, 19],     allow_nil: true
  validates_inclusion_of :handicap,   in: (0..9).to_a,     allow_nil: true
  validates_inclusion_of :komi,       in: [0.5, 5.5, 6.5], allow_nil: true
  validates_format_of    :moves,
                         with:      /\A(?:[a-s]{2})+(?:-(?:[a-s]{2})+)*\z/,
                         allow_nil: true
  
  attr_accessible :komi, :handicap, :board_size, :chosen_color
  
  ########################
  ### Instance Methods ###
  ########################

  attr_accessor :chosen_color, :creator
  
  def black_player_is_human?
    not black_player_id.blank?
  end
  
  def white_player_is_human?
    not white_player_id.blank?
  end
  
  def black_positions_list
    if black_positions       and
       @black_positions_list and
       @black_positions_list.size != black_positions.size / 2
       @black_positions_list = nil
    end
    @black_positions_list ||= black_positions.to_s.scan(/[a-s]{2}/)
  end
  
  def white_positions_list
    if white_positions       and
       @white_positions_list and
       @white_positions_list.size != white_positions.size / 2
       @white_positions_list = nil
    end
    @white_positions_list ||= white_positions.to_s.scan(/[a-s]{2}/)
  end
  
  def prepare
    color = chosen_color.blank? ? %w[white black].sample : chosen_color
    case color
    when "black"
      self.black_player = creator
    when "white"
      self.white_player = creator
    end
    if handicap.to_i.nonzero?
      game_engine do |engine|
        self.moves           = engine.move(:white)
        self.black_positions = engine.positions(:black)
        self.white_positions = engine.positions(:white)
      end
      self.current_player = black_player  # FIXME
    else
      self.current_player = black_player
    end
  end
  
  def move(vertex)
    game_engine do |engine|
      engine.replay(moves)
      played              = engine.move(:black, vertex)
      self.current_player = next_player
      if vertex == "RESIGN"
        finish_game(engine.final_score)
      elsif vertex == "PASS" and moves =~ /-\z/
        self.moves = moves.blank? ? played : [moves, ""].join("-")
        finish_game(engine.final_score)
      else
        self.moves           = moves.blank? ? played : [moves, played].join("-")
        self.black_positions = engine.positions(:black)
        self.white_positions = engine.positions(:white)
        p self
        response             = engine.move(:white)
        self.current_player  = next_player
        if response == "RESIGN"
          finish_game(engine.final_score)
        elsif response == "PASS" and vertex == "PASS"
          self.moves = [moves, ""].join("-")
          finish_game(engine.final_score)
        else
          self.moves           = [moves, response].join("-")
          self.black_positions = engine.positions(:black)
          self.white_positions = engine.positions(:white)
          p self
          self.black_score     = engine.captures(:black)
          self.white_score     = engine.captures(:white)
        end
      end
    end
  end
  
  def moves_after(index)
    moves.split('-')[index..-1].join('-') unless moves.nil?
  end
  
  def next_player
    current_player == black_player ? white_player : black_player
  end
  
  def finish_game(final_score)
    self.finished_at = Time.now
    if final_score =~ /\A([BW])\+(\d+\.\d+)\z/
      send("#{$1 == 'B' ? :black_score : :white_score}=", $2.to_f)
      send("#{$1 == 'B' ? :white_score : :black_score}=", 0)
    else
      raise "Unrecognized score format:  #{final_score}"
    end
  end
  
  def finished?
    not finished_at.blank?
  end
  
  def resigned?
    finished? and moves =~ /-{2}\z/
  end
  
  private
  
  def game_engine
    GameEngine.run( boardsize: board_size,
                    handicap:  handicap,
                    komi:      komi ) do |engine|
      yield engine
    end
  end
end
