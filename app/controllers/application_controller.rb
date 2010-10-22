class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  before_filter :mark_user_request, :if => :logged_in?

  private

  def mark_user_request
    current_user.update_attribute(:last_request_at, Time.now)
  end
end
