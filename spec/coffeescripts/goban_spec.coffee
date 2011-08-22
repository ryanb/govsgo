describe "Goban", ->
  it "has nice defaults", ->
    goban = new Goban
    expect(goban.size).toEqual(19)
    expect(goban.handicap).toEqual(0)
    expect(goban.moves).toEqual([])
    expect(goban.started).toEqual(false)
    expect(goban.finished).toEqual(false)

  it "sets attributes through constructor", ->
    goban = new Goban(size: 11, handicap: 9, moves: "aa-bb", started: true, finished: true)
    expect(goban.size).toEqual(11)
    expect(goban.handicap).toEqual(9)
    expect(goban.moves.length).toEqual(2)
    expect(goban.started).toEqual(true)
    expect(goban.finished).toEqual(true)

  it "sets current move index to last move", ->
    goban = new Goban(moves: "aa-bb-cc")
    expect(goban.currentMoveIndex).toEqual(3)

  it "sets current color to black when currentMoveIndex is even and no handicap", ->
    goban = new Goban(moves: "aa-bb")
    expect(goban.currentColor()).toEqual("b")
    goban.currentMoveIndex = 1
    expect(goban.currentColor()).toEqual("w")

  it "sets current color to white when currentMoveIndex is even with handicap", ->
    goban = new Goban(moves: "aa-bb", handicap: 2)
    expect(goban.currentColor()).toEqual("w")
    goban.currentMoveIndex = 1
    expect(goban.currentColor()).toEqual("b")

  it "applies the correct color to the moves", ->
    goban = new Goban(moves: "aa-bb")
    expect(goban.moves.length).toEqual(2)
    expect(goban.moves[0].color).toEqual("b")
