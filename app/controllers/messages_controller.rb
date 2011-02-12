class MessagesController < ApplicationController
  before_filter :user_required

  def create
    @message = Message.new(params[:message])
    @message.user = current_user
    @message.save
    Notifications.chat_message(@message).deliver if @message.send_email?
  end
end
