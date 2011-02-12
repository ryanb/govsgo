class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  before_filter :mark_user_request, :if => :logged_in?
  before_filter :set_user_time_zone, :if => :logged_in?

  private

  def mark_user_request
    current_user.update_attribute(:last_request_at, Time.now)
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if current_user.time_zone.present?
  end
end
