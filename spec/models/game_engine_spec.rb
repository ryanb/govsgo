require File.dirname(__FILE__) + '/../spec_helper'

describe GameEngine do
  before(:each) do
    @gtp = mock
    @engine = GameEngine.new(@gtp)
  end
  
  it "run should invoke GNU Go with game arguments" do
    Go::GTP.expects(:run_gnugo).with(arguments: "--boardsize 13")
    GameEngine.run(:boardsize => 13)
  end
  
  it "pass replay to gtp splitting moves into points" do
    @gtp.expects(:replay).with(%w[A17 A16])
    @engine.replay("acff-ad")
  end
  
  it "pass empty array of replay points when nil" do
    @gtp.expects(:replay).with([])
    @engine.replay(nil)
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
