require "spec_helper"

describe Notifications do
  it "invitation should send to current player of game" do
    game = Factory(:game)
    game.current_player = game.black_player
    mail = Notifications.invitation(game)
    mail.subject.should == "[Go vs Go] Invitation from #{game.white_player.username}"
    mail.to.should == [game.black_player.email]
    mail.from.should == ["noreply@govsgo.com"]
    mail.body.encoded.should include("unsubscribe")
  end

  it "move sends email about move" do
    game = Factory(:game)
    game.current_player = game.black_player
    mail = Notifications.move(game)
    mail.subject.should == "[Go vs Go] Move by #{game.white_player.username}"
    mail.to.should == [game.black_player.email]
    mail.from.should == ["noreply@govsgo.com"]
    mail.body.encoded.should include("unsubscribe")
  end
end
