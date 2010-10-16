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
  
  def moves_for_gnugo
    moves.to_s.split("-").map { |move| point(move[0..1]).to_gnugo(board_size) }
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
      if moves_for_gnugo.empty? or gnugo.replay(moves_for_gnugo)
        yield gnugo
      end
    end
  end
  
  def move(vertex)
    gnugo do |go|
      updated_moves = moves || ""
      whites_stones = go.list_stones(:white)
      if go.play(:black, point(vertex).to_gnugo(board_size))
        self.black_positions =  "#{black_positions}#{vertex}"
        captures             =  whites_stones - go.list_stones(:white)
        updated_moves        << "-" unless updated_moves.blank?
        updated_moves        << point(vertex).to_sgf
        updated_moves        << captures.map { |c| point(c).to_sgf }.join
        black_stones         =  go.list_stones(:black)
        computers_move       =  go.genmove(:white)
        if go.success?
          sgf                  =  point(computers_move).to_sgf
          self.white_positions =  "#{white_positions}#{sgf}"
          captures             =  black_stones - go.list_stones(:black)
          updated_moves        << "-#{point(computers_move).to_sgf}"
          updated_moves        << captures.map { |c| point(c).to_sgf }.join
        end
      end
      self.moves = updated_moves if moves != updated_moves
    end
  end
  
  private
  
  def point(*args)
    if args.size == 1 and /\A([A-HJ-T])(\d{1,2})\z/i
      args << {board_size: board_size}
    end
    Go::GTP::Point.new(*args)
  end
end
