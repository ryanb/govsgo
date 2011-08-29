describe "GoMove", ->
  it "has a position and color", ->
    move = new GoMove("aa")
    expect(move.position).toEqual("aa")
    expect(move.color).toEqual("b")

  it "parses out captured stones from position", ->
    move = new GoMove("aabbcc")
    expect(move.position).toEqual("aa")
    expect(move.captures).toEqual(["bb", "cc"])

  it "recognizes PASS", ->
    move = new GoMove("PASS")
    expect(move.isPass()).toEqual(true)
    move = new GoMove("aa")
    expect(move.isPass()).toEqual(false)

  it "recognizes RESIGN", ->
    move = new GoMove("RESIGN")
    expect(move.isResign()).toEqual(true)
    move = new GoMove("aa")
    expect(move.isResign()).toEqual(false)
