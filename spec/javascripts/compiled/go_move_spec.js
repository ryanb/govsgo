/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 22:34:54 GMT from
 * /Users/rbates/code/govsgo/spec/coffeescripts/go_move_spec.coffee
 */

(function() {
  describe("GoMove", function() {
    it("has a position and color", function() {
      var move;
      move = new GoMove("aa");
      expect(move.position).toEqual("aa");
      return expect(move.color).toEqual("b");
    });
    it("parses out captured stones from position", function() {
      var move;
      move = new GoMove("aabbcc");
      expect(move.position).toEqual("aa");
      return expect(move.captures).toEqual(["bb", "cc"]);
    });
    it("recognizes PASS", function() {
      var move;
      move = new GoMove("PASS");
      expect(move.isPass()).toEqual(true);
      move = new GoMove("aa");
      return expect(move.isPass()).toEqual(false);
    });
    return it("recognizes RESIGN", function() {
      var move;
      move = new GoMove("RESIGN");
      expect(move.isResign()).toEqual(true);
      move = new GoMove("aa");
      return expect(move.isResign()).toEqual(false);
    });
  });
}).call(this);
