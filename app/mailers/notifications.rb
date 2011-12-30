class Notifications < ActionMailer::Base
  default :from => "noreply@govsgo.com"

  def invitation(game)
    @game = game
    I18n.locale = @game.current_player.locale || I18n.default_locale
    mail :to => @game.current_player.email, :subject => t("invitation", :username => @game.opponent.username, :scope => "notifications")
  end

  def move(game)
    @game = game
    I18n.locale = @game.current_player.locale || I18n.default_locale
    mail :to => @game.current_player.email, :subject => t("move", :username => @game.opponent.username, :scope => "notifications")
  end

  def chat_message(message)
    @message = message
    I18n.locale = @message.recipient.locale || I18n.default_locale
    mail :to => @message.recipient.email, :subject => t("chat", :username => @message.user.username, :scope => "notifications")
  end
end
