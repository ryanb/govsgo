class Game < ActiveRecord::Base
  ###################
  ### Validations ###
  ###################
  
  validates_inclusion_of :board_size, in: (1..19).to_a,    allow_nil: true
  validates_inclusion_of :handicap,   in: (0..9).to_a,     allow_nil: true
  validates_inclusion_of :komi,       in: [0.5, 5.5, 6.5], allow_nil: true
  validates_format_of    :moves,
                         with:      /\A(?:[a-s]{2})+(?:-(?:[a-s]{2})+)*\z/,
                         allow_nil: true
  
  attr_accessible :komi, :handicap, :board_size
  
  ########################
  ### Instance Methods ###
  ########################
  
  def black_player_is_human?
    not black_player_id.blank?
  end
  
  def white_player_is_human?
    not white_player_id.blank?
  end
  
  def moves_for_gnugo
    moves.to_s.split("-")
    .map { |move| Go::GTP::Point.new(move[0..1]).to_gnugo(board_size) }
  end
  
  # 
  # Open a connection to GNU Go and reply the current game to the latest
  # position.  The block is passed this context.
  # 
  def gnugo
    arguments = {boardsize: board_size, handicap: handicap, komi: komi}
                .select { |_, setting|    not setting.nil?       }
                .map    { |name, setting| "--#{name} #{setting}" }
                .join(" ")
    Go::GTP.run_gnugo(arguments: arguments) do |gnugo|
      if moves_for_gnugo.empty? or gnugo.reply(moves_for_gnugo)
        yield gnugo
      end
    end
  end
end
