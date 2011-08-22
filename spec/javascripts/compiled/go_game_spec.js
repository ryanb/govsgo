/* DO NOT MODIFY. This file was compiled Fri, 19 Aug 2011 23:47:00 GMT from
 * /Users/rbates/code/govsgo/spec/coffeescripts/go_game_spec.coffee
 */

(function() {
  describe("GoGame", function() {
    beforeEach(function() {
      loadFixtures("game.html");
      return this.game = new GoGame;
    });
    return it("should include goban with settings from fixture", function() {
      var goban;
      goban = this.game.goban;
      expect(goban.handicap).toEqual(2);
      expect(goban.moves[0].color).toEqual("w");
      expect(goban.started).toEqual(true);
      expect(goban.finished).toEqual(false);
      return expect(goban.currentColor()).toEqual("b");
    });
  });
}).call(this);
