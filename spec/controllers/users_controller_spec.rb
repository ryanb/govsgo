require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :all
  render_views

  it "show action should render show template" do
    user = Factory(:user)
    get :show, :id => user
    response.should render_template(:show)
  end

  it "show action should report 404 for guest user" do
    user = Factory(:user, :guest => true)
    lambda {
      get :show, :id => user
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "new action should redirect to login when email exists" do
    user = Factory(:user)
    get :new, :email => user.email
    response.should redirect_to(login_url(:login => user.email))
  end

  it "new action should redirect to edit account page with email address when already logged in" do
    @controller.stubs(:current_user).returns(Factory(:user))
    get :new, :email => "foo"
    response.should redirect_to(edit_current_user_url(:email => "foo"))
  end

  it "create action should render new template when model is invalid" do
    User.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    User.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(root_url)
    cookies["token"].should == assigns["user"].token
  end

  it "edit action should redirect when not logged in" do
    get :edit, :id => "ignored"
    response.should redirect_to(signin_url)
  end

  it "edit action should render edit template" do
    @controller.stubs(:current_user).returns(User.first)
    get :edit, :id => "ignored"
    response.should render_template(:edit)
  end

  it "update action should redirect when not logged in" do
    put :update, :id => "ignored"
    response.should redirect_to(signin_url)
  end

  it "update action should render edit template when user is invalid" do
    @controller.stubs(:current_user).returns(User.first)
    User.any_instance.stubs(:valid?).returns(false)
    put :update, :id => "ignored"
    response.should render_template(:edit)
  end

  it "update action should redirect when user is valid" do
    @controller.stubs(:current_user).returns(User.first)
    User.any_instance.stubs(:valid?).returns(true)
    put :update, :id => "ignored"
    response.should redirect_to(root_url)
  end

  it "unsubscribe action should remove email options from user with matching token" do
    user = Factory(:user, :email_on_invitation => true, :email_on_move => true)
    get :unsubscribe, :token => user.unsubscribe_token
    response.should redirect_to(root_url)
  end

  it "publicize action should redirect when not logged in" do
    put :publicize, :id => "ignored"
    response.should redirect_to(signin_url)
  end

  it "publicize action should redirect to root url and update publicized_at time" do
    user = Factory(:user, :publicized_at => nil)
    @controller.stubs(:current_user).returns(user)
    put :publicize, :id => "ignored"
    response.should redirect_to(root_url)
    user.reload.publicized_at.to_date.should == Time.zone.now.to_date
  end

  it "publicize action should not allow guest" do
    user = Factory(:user, :publicized_at => nil, :guest => true)
    @controller.stubs(:current_user).returns(user)
    put :publicize, :id => "ignored"
    response.should redirect_to(signin_url)
    user.reload.publicized_at.should be_nil
    flash[:alert].should_not be_nil
  end

  it "publicize action should remove publicized_at time when asked" do
    user = Factory(:user, :publicized_at => Time.now)
    @controller.stubs(:current_user).returns(user)
    put :publicize, :id => "ignored", :remove => true
    response.should redirect_to(root_url)
    user.reload.publicized_at.should be_nil
  end
end
