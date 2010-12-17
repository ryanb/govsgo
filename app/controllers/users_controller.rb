class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :unsubscribe]

  def new
    if params[:email]
      if logged_in?
        flash[:notice] = "Please update your profile below."
        redirect_to edit_current_user_url(:email => params[:email])
      elsif User.find_by_email(params[:email])
        flash[:notice] = "It appears you already have an account, please login below."
        redirect_to login_url(:login => params[:email])
      end
    end
    @user = User.new(:email => params[:email], :email_on_invitation => true)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      remember_user(@user)
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
    if params[:email]
      @user.email = params[:email]
    end
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

  def unsubscribe
    @user = User.find_by_unsubscribe_token!(params[:token])
    @user.update_attributes!(:email_on_invitation => false, :email_on_move => false)
    flash[:notice] = "You have been unsubscribed from further email notifications."
    redirect_to root_url
  end

  def publicize
    if guest?
      redirect_to signin_url, :alert => "You must first sign in to be added to the Looking for Games list."
    else
      @user = current_user
      @user.update_attribute(:publicized_at, (params[:remove] ? nil : Time.now))
      redirect_to root_url, :notice => "You have been #{params[:remove] ? 'removed from' : 'added to'} the Looking for Games list."
    end
  end
end
