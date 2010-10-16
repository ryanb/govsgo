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
  
  attr_accessible :komi, :handicap, :board_size
  
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
  
  def move(vertex)
    GameEngine.run( boardsize: board_size,
                    handicap:  handicap,
                    komi:      komi ) do |engine|
      engine.replay(moves)
      self.moves           = [ moves,
                               engine.move(:black, vertex),
                               engine.move(:white) ].reject(&:blank?).join('-')
      self.black_positions = engine.positions(:black)
      self.white_positions = engine.positions(:white)
    end
  end
  
  def moves_after(index)
    moves.split('-')[index..-1].join('-') unless moves.nil?
  end
  
  def chosen_color=(color)
    color = %w[white black].sample if color.blank?
    case color
    when "black" then self.black_player = self.current_player = creator
    when "white" then self.white_player = creator
    end
  end
  
  def chosen_color
    if creator == black_player
      "black"
    elsif creator == white_player
      "white"
    end
  end
end
