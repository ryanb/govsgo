require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  fixtures :all
  render_views

  describe "as guest" do
    it "create action should redirect to signin url" do
      get :create
      response.should redirect_to(signin_url)
    end
  end

  describe "as user" do
    before(:each) do
      @user = Factory(:user)
      @controller.stubs(:current_user).returns(@user)
    end

    it "create action should render js template" do
      Message.any_instance.stubs(:valid?).returns(true)
      post :create, :format => "js"
      response.should render_template("create")
      assigns(:message).user == @user
    end
  end
end
