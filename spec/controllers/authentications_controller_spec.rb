require File.dirname(__FILE__) + '/../spec_helper'

describe AuthenticationsController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should redirect to root after logging in a user when authentication is found" do
    user = Factory(:user)
    user.authentications.create!(:provider => "foo", :uid => "123")
    request.env["omniauth.auth"] = {"provider" => "foo", "uid" => "123"}
    post :create
    response.should redirect_to(root_url)
    session[:user_id].should == user.id
  end

  it "create action should add authentication when logged in to a full user" do
    user = Factory(:user)
    @controller.stubs(:current_user).returns(user)
    request.env["omniauth.auth"] = {"provider" => "bar", "uid" => "456"}
    post :create
    user.authentications.first.uid.should == "456"
    response.should redirect_to(edit_current_user_url)
  end

  it "create action should make guest when not logged in and redirect to edit current user url when not valid" do
    request.env["omniauth.auth"] = {"provider" => "bar", "uid" => "789", "user_info" => {}}
    post :create
    response.should redirect_to(edit_current_user_url)
    session[:user_id].should_not be_nil
    session[:omniauth].should_not be_nil
  end

  it "create action should make guest when not logged in and redirect to root url when valid" do
    User.delete_all
    Authentication.delete_all
    request.env["omniauth.auth"] = {"provider" => "bar", "uid" => "123", "user_info" => {"email" => "foo@example.com", "nickname" => "foo"}}
    post :create
    response.should redirect_to(root_url)
    session[:user_id].should_not be_nil
    session[:omniauth].should be_nil
  end

  it "destroy action should destroy model and redirect edit user path" do
    user = Factory(:user)
    @controller.stubs(:current_user).returns(user)
    authentication = user.authentications.create!(:provider => 1, :uid => 2)
    delete :destroy, :id => authentication
    response.should redirect_to(edit_current_user_path)
    Authentication.exists?(authentication.id).should be_false
  end

  it "create action should log in user and merge guest games into user" do
    guest = User.create!(:guest => true)
    @controller.stubs(:current_user).returns(guest)
    game = Factory(:game, :black_player => guest)
    user = Factory(:user)
    user.authentications.create!(:provider => "foo", :uid => "123")
    request.env["omniauth.auth"] = {"provider" => "foo", "uid" => "123"}
    post :create
    response.should redirect_to(root_url)
    session[:user_id].should == user.id
    game.reload.black_player.should == user
  end
end
