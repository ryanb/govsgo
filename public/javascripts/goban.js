/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 23:02:36 GMT from
 * /Users/rbates/code/govsgo/app/coffeescripts/goban.coffee
 */

(function() {
  var Goban;
  Goban = (function() {
    function Goban(options) {
      if (options == null) {
        options = {};
      }
      this.size = 19;
      this.handicap = 0;
      this.started = false;
      this.finished = false;
      this.moves = [];
      this.currentMoveIndex = 0;
      if (options.size) {
        this.size = options.size;
      }
      if (options.handicap) {
        this.handicap = options.handicap;
      }
      if (options.started) {
        this.started = options.started;
      }
      if (options.finished) {
        this.finished = options.finished;
      }
      if (options.moves) {
        this.addMoves(options.moves);
      }
    }
    Goban.prototype.addMoves = function(moves) {
      var move, _i, _len, _ref, _results;
      _ref = moves.split("-");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        move = _ref[_i];
        this.moves.push(new GoMove(move, this.currentColor()));
        _results.push(this.currentMoveIndex++);
      }
      return _results;
    };
    Goban.prototype.currentColor = function() {
      if (this.handicap > 0) {
        if (this.currentMoveIndex % 2) {
          return "b";
        } else {
          return "w";
        }
      } else {
        if (this.currentMoveIndex % 2) {
          return "w";
        } else {
          return "b";
        }
      }
    };
    return Goban;
  })();
  this.Goban = Goban;
}).call(this);
