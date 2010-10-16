class GameEngine
  def self.run(options = { }, &block)
    arguments = options.map { |k, v| "--#{k} #{v}" unless v.blank? }.join(" ")
    Go::GTP.run_gnugo(arguments: arguments) do |gtp|
      yield GameEngine.new(gtp, options)
    end
  end
  
  def initialize(gtp, options = {})
    @gtp        = gtp
    @board_size = options[:boardsize] || 19
  end
  
  def replay(moves)
    @gtp.replay(moves.to_s.split("-").map { |move| gnugo_point(move[0..1]) })
  end
  
  def move(color, vertex = nil)
    other_stones = @gtp.list_stones(opposite(color))
    if vertex
      @gtp.play(color, gnugo_point(vertex))
    else
      vertex = sgf_point(@gtp.genmove(color))
    end
    captured = other_stones - @gtp.list_stones(opposite(color))
    vertex   + captured.map { |v| sgf_point(v) }.join
  end
  
  def positions(color)
    @gtp.list_stones(color).map { |v| sgf_point(v) }.join
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
    point(vertex).to_gnugo(@board_size)
  end
  
  def sgf_point(vertex)
    point(vertex).to_sgf
  end
  
  def opposite(color)
    color == :black ? :white : :black
  end
end
