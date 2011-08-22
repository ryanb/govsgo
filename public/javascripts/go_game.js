/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 23:45:03 GMT from
 * /Users/rbates/code/govsgo/app/coffeescripts/go_game.coffee
 */

(function() {
  var GoGame;
  GoGame = (function() {
    function GoGame() {
      this.goban = new Goban({
        handicap: $('#board').data('handicap'),
        moves: $('#board').data('moves'),
        started: $('#board').data('started'),
        finished: $('#board').data('finished')
      });
    }
    return GoGame;
  })();
  this.GoGame = GoGame;
}).call(this);
