describe "GoGame", ->
  beforeEach ->
    loadFixtures("game.html")
    @game = new GoGame

  it "should include goban with settings from fixture", ->
    goban = @game.goban
    expect(goban.handicap).toEqual(2)
    expect(goban.moves[0].color).toEqual("w")
    expect(goban.started).toEqual(true)
    expect(goban.finished).toEqual(false)
    expect(goban.currentColor()).toEqual("b")
