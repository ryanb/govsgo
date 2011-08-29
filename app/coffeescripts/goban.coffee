class @Goban
  constructor: (options = {}) ->
    @size = options.size || 19
    @handicap = options.handicap || 0
    @started = options.started || false
    @finished = options.finished || false
    @blackPositions = []
    @whitePositions = []
    @currentMoveIndex = 0
    @moves = []
    @addMove(move) for move in options.moves.split("-") if options.moves

  addMove: (moveString) ->
    move = new GoMove(moveString, @currentColor())
    @moves.push(move)
    if move.color == "b"
      @blackPositions.push(move.position)
      @whitePositions = _.difference(@whitePositions, move.captures)
    else
      @whitePositions.push(move.position)
      @blackPositions = _.difference(@blackPositions, move.captures)
    @currentMoveIndex++
    move

  currentColor: ->
    if @handicap > 0
      if @currentMoveIndex % 2 then "b" else "w"
    else
      if @currentMoveIndex % 2 then "w" else "b"

  captured: (color) ->
    total = 0
    for move in @moves
      total += move.captures.length if move.color == color
    total
