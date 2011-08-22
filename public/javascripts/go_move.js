/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 22:34:54 GMT from
 * /Users/rbates/code/govsgo/app/coffeescripts/go_move.coffee
 */

(function() {
  var GoMove;
  GoMove = (function() {
    GoMove.prototype.captures = [];
    function GoMove(move, color) {
      var index, position, _len, _ref;
      this.move = move;
      this.color = color != null ? color : "b";
      if (!this.isResign() && !this.isPass()) {
        _ref = this.move.match(/../g);
        for (index = 0, _len = _ref.length; index < _len; index++) {
          position = _ref[index];
          if (index === 0) {
            this.position = position;
          } else {
            this.captures.push(position);
          }
        }
      }
    }
    GoMove.prototype.isResign = function() {
      return this.move === "RESIGN";
    };
    GoMove.prototype.isPass = function() {
      return this.move === "PASS";
    };
    return GoMove;
  })();
  this.GoMove = GoMove;
}).call(this);
