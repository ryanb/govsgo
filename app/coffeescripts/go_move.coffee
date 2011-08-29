class @GoMove
  constructor: (@move, @color = "b") ->
    @captures = []
    if !@isResign() && !@isPass()
      for position, index in @move.match(/../g)
        if index == 0
          @position = position
        else
          @captures.push(position)

  isResign: ->
    @move == "RESIGN"

  isPass: ->
    @move == "PASS"
