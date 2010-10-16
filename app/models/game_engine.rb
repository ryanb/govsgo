class GameEngine
  def self.sgf_to_gnugo(sgf_moves)
    sgf_moves.to_s.split("-").map { |move| gnugo_point(move[0..1]) }
  end
  
  def self.run(options = { }, &block)
    Go::GTP.run_gnugo do |gtp|
      gtp.boardsize(options[:boardsize])     unless options[:boardsize].blank?
      gtp.fixed_handicap(options[:handicap]) if options[:handicap].to_i.nonzero?
      gtp.komi(options[:komi])               unless options[:komi].blank?
      yield GameEngine.new(gtp, options)
    end
  end
  
  def initialize(gtp, options = { })
    @gtp        = gtp
    @board_size = options[:boardsize] || 19
  end
  
  def replay(moves, first_color)
    @gtp.replay(self.class.sgf_to_gnugo(moves), first_color)
  end
  
  def move(color, vertex = nil)
    other_stones = @gtp.list_stones(opposite(color))
    if vertex
      @gtp.play(color, gnugo_point(vertex))
    else
      vertex = sgf_point(@gtp.genmove(color))
    end
    captured = other_stones - @gtp.list_stones(opposite(color))
    sgf_point(vertex)   + captured.map { |v| sgf_point(v) }.join
  end
  
  def positions(color)
    @gtp.list_stones(color).map { |v| sgf_point(v) }.join
  end
  
  def legal_moves(color)
    @gtp.all_legal(color).map { |v| sgf_point(v) }.join
  end
  
  def captures(color)
    @gtp.captures(color)
  end
  
  def final_score
    @gtp.final_score
  end
  
  private
  
  def point(vertex)
    args = [vertex]
    if vertex =~ /\A[A-HJ-T](?:1\d|[1-9])\z/
      args << {board_size: @board_size}
    end
    Go::GTP::Point.new(*args)
  end
  
  def gnugo_point(vertex)
    return "PASS"             if vertex.blank?
    return vertex.to_s.upcase if %w[PASS RESIGN].include? vertex.to_s.upcase
    point(vertex).to_gnugo(@board_size)
  end
  
  def sgf_point(vertex)
    return vertex.to_s.upcase if %w[PASS RESIGN].include? vertex.to_s.upcase
    point(vertex).to_sgf
  end
  
  def opposite(color)
    color == :black ? :white : :black
  end
end
