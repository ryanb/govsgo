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
      @engine.replay("ab-cc-ba", :black)
      lambda {
        @engine.move(:black, "aa")
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
      GameEngine.run(:boardsize => 13) { }
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

    it "pass replay to gtp splitting moves into points" do
      @gtp.expects(:replay).with(%w[A17 A16], "black")
      @engine.replay("acff-ad", "black")
    end

    it "pass empty array of replay points when nil" do
      @gtp.expects(:replay).with([], "black")
      @engine.replay(nil, "black")
    end

    it "should move stone and return point back" do
      @gtp.stubs(:list_stones).with(:white).returns(%w[A17 A16])
      @gtp.expects(:play).with(:black, "A18")
      @engine.move(:black, "ab").should == "ab"
    end

    it "should move stone and return point back with captures" do
      @gtp.expects(:play).with(:black, "A18")
      @gtp.expects(:list_stones).with(:white).returns(%w[A16]) # it mocks them in reverse order
      @gtp.expects(:list_stones).with(:white).returns(%w[A17 A16])
      @engine.move(:black, "ab").should == "abac"
    end

    it "should call genmove when move position isn't given" do
      @gtp.stubs(:list_stones).with(:white).returns(%w[A17 A16])
      @gtp.expects(:genmove).with(:black).returns("A18")
      @engine.move(:black).should == "ab"
    end

    it "should convert black positions to points" do
      @gtp.stubs(:list_stones).with(:black).returns(%w[A17 A16])
      @engine.positions(:black).should == "acad"
    end
  end
end
