class Notifications < ActionMailer::Base
  default :from => "noreply@govsgo.com"

  def invitation(game)
    @game = game
    mail :to => @game.current_player.email, :subject => "[Go vs Go] Invitation from #{@game.opponent.username}"
  end

  def move(game)
    @game = game
    mail :to => @game.current_player.email, :subject => "[Go vs Go] Move by #{@game.opponent.username}"
  end
end
