class MessagesController < ApplicationController
  before_filter :user_required

  def create
    @message = Message.new(params[:message])
    @message.user = current_user
    @message.save
  end
end
