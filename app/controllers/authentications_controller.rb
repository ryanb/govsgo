class AuthenticationsController < ApplicationController
  def index
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      current_user.move_games_to(authentication.user) if current_user && current_user.guest?
      authentication.user.apply_omniauth(omniauth)
      authentication.user.save!
      remember_user(authentication.user)
      flash[:notice] = "Signed in as #{authentication.user.username}"
      redirect_to_target_or_default root_url
    else
      user = current_user_or_guest
      user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.apply_omniauth(omniauth)
      was_guest = user.guest?
      user.guest = false
      if user.save
        if was_guest
          flash[:notice] = "Signed in as #{user.username}."
          remember_user(user)
          redirect_to_target_or_default root_url
        else
          flash[:notice] = "Authentication successful."
          redirect_to edit_current_user_url
        end
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to edit_current_user_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to edit_current_user_path
  end
end
