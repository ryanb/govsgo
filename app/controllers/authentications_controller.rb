class AuthenticationsController < ApplicationController
  def index
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      remember_user(authentication.user)
      redirect_to root_url
    else
      user = current_user_or_guest
      user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.apply_omniauth(omniauth)
      was_guest = user.guest?
      user.guest = false
      if user.save
        if was_guest
          flash[:notice] = "Signed in successfully."
          remember_user(user)
          redirect_to root_url
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
