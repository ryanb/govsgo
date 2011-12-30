class SessionsController < ApplicationController
  after_filter :change_locale, :only => [:create]

  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      remember_user(user)
      flash[:notice] = t("create_success", :scope => "controllers.sessions")
      redirect_to_target_or_default("/")
    else
      flash.now[:alert] = t("create_fail", :scope => "controllers.sessions")
      render :action => 'new'
    end
  end

  def destroy
    forget_user
    flash[:notice] = t("destroy", :scope => "controllers.sessions")
    redirect_to root_url
  end
end
