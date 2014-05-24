# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%= current_user.username %>.
#     <%= link_to "Edit profile", edit_user_path %> or
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
module ControllerAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?, :guest?, :redirect_to_target_or_default
  end

  def current_user
    @current_user ||= fetch_current_user
  end

  def fetch_current_user
    if session[:user_id]
      User.find_by_id(session[:user_id])
    elsif cookies[:token]
      User.find_by_token(cookies[:token])
    end
  end

  def current_user_or_guest
    unless logged_in?
      @current_user = User.create!(:guest => true)
      remember_user(@current_user)
    end
    current_user
  end

  def logged_in?
    current_user
  end

  def guest?
    current_user.nil? || current_user.guest?
  end

  def login_required(message = t("login_required", :scope => "controllers.authentications"))
    unless logged_in?
      flash[:alert] = message
      store_target_location
      redirect_to signin_url
    end
  end

  def user_required(message = t("user_required", :scope => "controllers.authentications"))
    if guest?
      flash[:alert] = message
      store_target_location
      redirect_to signin_url
    end
  end

  def redirect_to_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def remember_user(user)
    cookies.permanent[:token] = user.token
  end

  def forget_user
    session[:user_id] = nil
    cookies.delete(:token)
  end

  private

  def store_target_location
    session[:return_to] = request.url
  end
end
