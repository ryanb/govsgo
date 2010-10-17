class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create]

  def new
    if params[:email] && User.find_by_email(params[:email])
      redirect_to login_url(:email => params[:email])
    end
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.guest = false
    if @user.save
      session[:omniauth] = nil
      flash[:notice] = "Your profile has been updated."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
end
