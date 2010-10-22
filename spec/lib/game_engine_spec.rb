require File.dirname(__FILE__) + '/../spec_helper'

describe GameEngine do
  describe "without gtp stub" do
    before(:each) do
      @gtp = Go::GTP.run_gnugo
      @engine = GameEngine.new(@gtp)
    end

    after(:each) do
      @gtp.quit
    end

    it "should raise illegal suicide move when placing a stone in surrounding stones" do
      @engine.replay("ab-cc-ba")
      lambda {
        @engine.move(:white, "aa")
      }.should raise_error(GameEngine::IllegalMove)
    end

    it "should report back captured stones for black" do
      @engine.replay("dd-aa-ab-cc")
      @engine.move("black", "ba").should == "baaa"
    end

    it "should report back captured stones for white" do
      @engine.replay("aa-ab-cc")
      @engine.move("white", "ba").should == "baaa"
    end

    it "should allow black to place stone with surrounding black stones" do
      @engine.replay("ab-cc-ba-dd")
      @engine.move("black", "aa").should == "aa"
    end

    it "should end game when resigning" do
      @engine.replay("ab-cc-ba-dd")
      @engine.move("black", "RESIGN").should == "RESIGN"
      @engine.should be_over
      @engine.black_score.should == 0
      @engine.white_score.should == 1
    end

    it "should report illegal move when playing after resigning" do
      @engine.replay("aa-RESIGN")
      lambda {
        @engine.move("black", "bb")
      }.should raise_error(GameEngine::IllegalMove)
    end
  end

  describe "with gtp stub" do
    before(:each) do
      @gtp = mock
      @gtp.stubs(:success?).returns(true)
      @engine = GameEngine.new(@gtp)
    end

    it "run should invoke GNU Go with the proper boardsize" do
      Go::GTP.expects(:run_gnugo).yields(@gtp)
      @gtp.expects(:boardsize).with(13)
      GameEngine.run(:board_size => 13) { }
    end

    it "run should invoke GNU Go with non-zero handicaps" do
      Go::GTP.expects(:run_gnugo).yields(@gtp)
      @gtp.expects(:fixed_handicap).with(2)
      GameEngine.run(:handicap => 2) { }
    end

    it "run should invoke GNU Go with the proper komi" do
      Go::GTP.expects(:run_gnugo).yields(@gtp)
      @gtp.expects(:komi).with(5.5)
      GameEngine.run(:komi => 5.5) { }
    end

    it "should call play for each move on replay passing in GNU Go position" do
      @gtp.expects(:play).with(:white, "A16")
      @gtp.expects(:play).with(:black, "A17")
      @engine.replay("acff-ad")
    end

    it "should do nothing for replay when passing an nil for moves" do
      @engine.replay(nil)
    end

    it "should replay pass and resign correctly" do
      @gtp.expects(:play).with(:black, "PASS")
      @engine.replay("PASS-RESIGN")
    end

    it "should move stone and return point back" do
      @gtp.stubs(:over?).returns(false)
      @gtp.stubs(:list_stones).with(:white).returns(%w[A17 A16])
      @gtp.expects(:play).with(:black, "A18")
      @engine.move(:black, "ab").should == "ab"
    end

    it "should move stone and return point back with captures" do
      @gtp.stubs(:over?).returns(false)
      @gtp.expects(:play).with(:black, "A18")
      @gtp.expects(:list_stones).with(:white).returns(%w[A16]) # it mocks them in reverse order
      @gtp.expects(:list_stones).with(:white).returns(%w[A17 A16])
      @engine.move(:black, "ab").should == "abac"
    end

    it "should call genmove when move position isn't given" do
      @gtp.stubs(:over?).returns(false)
      @gtp.stubs(:list_stones).with(:white).returns(%w[A17 A16])
      @gtp.expects(:genmove).with(:black).returns("A18")
      @engine.move(:black).should == "ab"
    end

    it "should convert black positions to points" do
      @gtp.stubs(:list_stones).with(:black).returns(%w[A17 A16])
      @engine.positions(:black).should == "acad"
    end

    it "should determine scores when black wins" do
      @gtp.stubs(:final_score).returns("B+70.5")
      @engine.black_score.should == 70.5
      @engine.white_score.should == 0
    end

    it "should determine scores when white wins" do
      @gtp.stubs(:final_score).returns("W+35.5")
      @engine.black_score.should == 0
      @engine.white_score.should == 35.5
    end

    it "should return PASS as move when passing" do
      @gtp.stubs(:over?).returns(false)
      @gtp.expects(:play).with(:black, "PASS")
      @engine.move(:black, "PASS").should == "PASS"
    end

    it "should be over when genmove returns resign" do
      @gtp.stubs(:over?).returns(false)
      @gtp.stubs(:list_stones).with(:white).returns(%w[A17 A16])
      @gtp.expects(:genmove).with(:black).returns("resign")
      @engine.move(:black).should == "RESIGN"
      @engine.should be_over
    end

    it "should be finished when gtp says game is over" do
      @gtp.stubs(:over?).returns(true)
      @engine.should be_over
    end

    it "should have black be first color by default" do
      @engine.first_color.should == :black
    end

    it "should have white be first color when handicap is used" do
      GameEngine.new(nil, :handicap => 2).first_color.should == :white
    end
  end
end
