require 'spec_helper'

describe MovesController do
  fixtures :all
  render_views

  it "should show moves in game" do
    game = Factory(:game, :moves => "aa-bb-cc")
    get "index", :game_id => game.id, :format => "js", :after => 1
    response.body.should include("\"bb-cc\"")
  end

  it "should add a move and respond with javascript and send email if user requests" do
    game = Factory(:game)
    game.opponent.update_attribute(:email_on_move, true)
    @controller.stubs(:current_user).returns(game.current_player)
    post "create", :game_id => game.id, :format => "js", :move => "aa"
    response.should be_success
    game.reload
    Notifications.deliveries.size.should == 1
    Notifications.deliveries.first.subject.should == "[Go vs Go] Move by #{game.opponent.username}"
  end

  it "should not send move email when user doesn't want it" do
    game = Factory(:game)
    @controller.stubs(:current_user).returns(game.current_player)
    post "create", :game_id => game.id, :format => "js", :move => "aa"
    response.should be_success
    Notifications.deliveries.size.should == 0
  end

  # It used to not behave this way but it caused some confusion as to why it sometimes wouldn't send notifications
  it "should send move email even when user is online" do
    game = Factory(:game)
    game.opponent.update_attribute(:email_on_move, true)
    game.opponent.update_attribute(:last_request_at, Time.now)
    @controller.stubs(:current_user).returns(game.current_player)
    post "create", :game_id => game.id, :format => "js", :move => "aa"
    response.should be_success
    Notifications.deliveries.size.should == 1
  end
end
