class UsersController < ApplicationController
  before_filter :login_required, :except => [:show, :new, :create, :unsubscribe]
  after_filter :change_locale, :only => [:create, :update]

  def show
    @user = User.where(:guest => false).find(params[:id])
    @games = @user.games.recent.paginate(:per_page => 5, :page => params[:page])
  end

  def new
    if params[:email]
      if logged_in?
        flash[:notice] = t("new_update", :scope => "controllers.users")
        redirect_to edit_current_user_url(:email => params[:email])
      elsif User.find_by_email(params[:email])
        flash[:notice] = t("new_login", :scope => "controllers.users")
        redirect_to login_url(:login => params[:email])
      end
    end
    @user = User.new(:email => params[:email], :email_on_invitation => true)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      remember_user(@user)
      flash[:notice] = t("create", :scope => "controllers.users")
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
      flash[:notice] = t("update", :scope => "controllers.users")
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

  def unsubscribe
    @user = User.find_by_unsubscribe_token!(params[:token])
    @user.update_attributes!(:email_on_invitation => false, :email_on_move => false, :email_on_message => false)
    flash[:notice] = t("unsubscribe", :scope => "controllers.users")
    redirect_to root_url
  end

  def publicize
    if guest?
      redirect_to signin_url, :alert => t("publicize_guest", :scope => "controllers.users")
    else
      @user = current_user
      @user.update_attribute(:publicized_at, (params[:remove] ? nil : Time.now))
      redirect_to root_url, :notice => t(params[:remove] ? "publicize_remove" : "publicize_add", :scope => "controllers.users")
    end
  end
end
