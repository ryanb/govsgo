require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  fixtures :all
  render_views

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when authentication is invalid" do
    User.stubs(:authenticate).returns(nil)
    post :create
    response.should render_template(:new)
    cookies["token"].should be_nil
  end

  it "create action should redirect when authentication is valid" do
    user = Factory(:user)
    User.stubs(:authenticate).returns(user)
    post :create
    response.should redirect_to("/")
    cookies["token"].should == user.token
  end
end
