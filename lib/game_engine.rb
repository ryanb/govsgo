class GameEngine
  class Error < StandardError; end
  class IllegalMove < Error; end
  class OutOfTurn < Error; end

  def self.run(options = {})
    Go::GTP.run_gnugo do |gtp|
      gtp.boardsize(options[:board_size]) unless options[:board_size].to_s.empty?
      gtp.fixed_handicap(options[:handicap]) if options[:handicap].to_i.nonzero?
      gtp.komi(options[:komi]) unless options[:komi].to_s.empty?
      yield GameEngine.new(gtp, options)
    end
  end

  def self.update_game_attributes_with_move(game, move = nil)
    update = {}
    run(game) do |engine|
      update.merge!(engine.update_game_attributes_with_move(game, move))
    end
    update
  end

  def initialize(gtp, options = {})
    @resigned = nil
    @gtp = gtp
    @board_size = options[:board_size] || 19
    @handicap = options[:handicap].to_i
    @current_color = @handicap > 0 ? :white : :black
  end

  def replay(moves)
    moves.to_s.split("-").each do |move|
      play(move =~ /[A-Z]/ ? move : move[0..1])
    end
  end

  # Play at the given position, nil for computer play
  def play(position = nil)
    if position.nil?
      position = sgf_point(@gtp.genmove(@current_color))
    else
      @gtp.play(@current_color, gnugo_point(position)) unless position == "RESIGN"
      raise IllegalMove unless @gtp.success?
    end
    if position == "RESIGN"
      @resigned = @current_color
    end
    @current_color = opposite_color
    position
  end

  # Play the move and include the captured stones afterwards
  def move(position = nil)
    raise IllegalMove if over?
    if %w[PASS RESIGN].include? position
      play(position)
    else
      other_color = opposite_color
      other_stones = @gtp.list_stones(other_color)
      position = play(position)
      captured = other_stones - @gtp.list_stones(other_color)
      position + captured.map { |v| sgf_point(v) }.join
    end
  end

  def update_game_attributes_with_move(game, move = nil)
    update = {}
    replay(game[:moves])
    update[:moves] = [game[:moves].to_s, move(move)].reject(&:empty?).join("-")
    update[:last_move_at] = Time.now
    update[:black_positions] = positions(:black)
    update[:white_positions] = positions(:white)
    update[:current_player_id] = game["#{@current_color}_player_id".to_sym]
    if over?
      update[:finished_at] = Time.now
      update[:black_score] = score(:black)
      update[:white_score] = score(:white)
    else
      update[:black_score] = captures(:black)
      update[:white_score] = captures(:white)
    end
    update
  end

  def positions(color)
    @gtp.list_stones(color).map { |v| sgf_point(v) }.join
  end

  def captures(color)
    @gtp.captures(color)
  end

  def over?
    @resigned || @gtp.over?
  end

  def score(color)
    if @resigned
      @resigned.to_sym == color.to_sym ? 0 : 1
    else
      @gtp.final_score[/^#{color.to_s[0].upcase}\+([\d\.]+)$/, 1].to_f
    end
  end

  private

  def opposite_color
    @current_color == :black ? :white : :black
  end

  def point(position)
    args = [position]
    if position =~ /\A[A-HJ-T](?:1\d|[1-9])\z/
      args << {:board_size => @board_size}
    end
    Go::GTP::Point.new(*args)
  end

  def gnugo_point(position)
    if %w[PASS RESIGN].include? position.to_s.upcase
      position.to_s.upcase
    else
      point(position).to_gnugo(@board_size)
    end
  end

  def sgf_point(position)
    if %w[PASS RESIGN].include? position.to_s.upcase
      position.to_s.upcase
    else
      point(position).to_sgf
    end
  end
end
