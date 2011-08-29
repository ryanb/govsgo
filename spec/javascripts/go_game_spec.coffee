describe "GoGame", ->
  beforeEach ->
    loadFixtures("game.html")
    @game = new GoGame

  it "includes goban with settings from fixture", ->
    goban = @game.goban
    expect(goban.handicap).toEqual(2)
    expect(goban.moves[0].color).toEqual("w")
    expect(goban.started).toEqual(true)
    expect(goban.finished).toEqual(false)
    expect(goban.currentColor()).toEqual("b")

  it "updates goban and view when playing a move", ->
    @game.move("aa")
    expect(@game.goban.blackPositions).toContain("aa")
    expect($('#board_spaces #aa').attr("class")).toEqual("b")
    @game.move("bbaa")
    expect($('#board_spaces #bb').attr("class")).toEqual("w")
    expect($('#board_spaces #aa').attr("class")).toEqual("e")
