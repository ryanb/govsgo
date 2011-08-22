class Goban
  constructor: (options = {}) ->
    @size = 19
    @handicap = 0
    @started = false
    @finished = false
    @moves = []
    @currentMoveIndex = 0
    @size = options.size if options.size
    @handicap = options.handicap if options.handicap
    @started = options.started if options.started
    @finished = options.finished if options.finished
    @addMoves(options.moves) if options.moves

  addMoves: (moves) ->
    for move in moves.split("-")
      @moves.push new GoMove(move, @currentColor())
      @currentMoveIndex++

  currentColor: ->
    if @handicap > 0
      if @currentMoveIndex % 2 then "b" else "w"
    else
      if @currentMoveIndex % 2 then "w" else "b"

@Goban = Goban
