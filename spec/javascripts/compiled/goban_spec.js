/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 22:49:24 GMT from
 * /Users/rbates/code/govsgo/spec/coffeescripts/goban_spec.coffee
 */

(function() {
  describe("Goban", function() {
    it("has nice defaults", function() {
      var goban;
      goban = new Goban;
      expect(goban.size).toEqual(19);
      expect(goban.handicap).toEqual(0);
      expect(goban.moves).toEqual([]);
      expect(goban.started).toEqual(false);
      return expect(goban.finished).toEqual(false);
    });
    it("sets attributes through constructor", function() {
      var goban;
      goban = new Goban({
        size: 11,
        handicap: 9,
        moves: "aa-bb",
        started: true,
        finished: true
      });
      expect(goban.size).toEqual(11);
      expect(goban.handicap).toEqual(9);
      expect(goban.moves.length).toEqual(2);
      expect(goban.started).toEqual(true);
      return expect(goban.finished).toEqual(true);
    });
    it("sets current move index to last move", function() {
      var goban;
      goban = new Goban({
        moves: "aa-bb-cc"
      });
      return expect(goban.currentMoveIndex).toEqual(3);
    });
    it("sets current color to black when currentMoveIndex is even and no handicap", function() {
      var goban;
      goban = new Goban({
        moves: "aa-bb"
      });
      expect(goban.currentColor()).toEqual("b");
      goban.currentMoveIndex = 1;
      return expect(goban.currentColor()).toEqual("w");
    });
    it("sets current color to white when currentMoveIndex is even with handicap", function() {
      var goban;
      goban = new Goban({
        moves: "aa-bb",
        handicap: 2
      });
      expect(goban.currentColor()).toEqual("w");
      goban.currentMoveIndex = 1;
      return expect(goban.currentColor()).toEqual("b");
    });
    return it("applies the correct color to the moves", function() {
      var goban;
      goban = new Goban({
        moves: "aa-bb"
      });
      expect(goban.moves.length).toEqual(2);
      return expect(goban.moves[0].color).toEqual("b");
    });
  });
}).call(this);
