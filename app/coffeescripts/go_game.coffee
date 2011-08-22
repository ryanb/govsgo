class GoGame
  constructor: ->
    @goban = new Goban
      handicap: $('#board').data('handicap')
      moves: $('#board').data('moves')
      started: $('#board').data('started')
      finished: $('#board').data('finished')


@GoGame = GoGame