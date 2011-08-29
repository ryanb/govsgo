class @GoGame
  constructor: ->
    @goban = new Goban
      handicap: $('#board').data('handicap')
      moves: $('#board').data('moves')
      started: $('#board').data('started')
      finished: $('#board').data('finished')

  move: (moveString) ->
    move = @goban.addMove(moveString)
    $("\##{move.position}").attr("class", move.color)
    for capture in move.captures
      $("\##{capture}").attr("class", "e")
