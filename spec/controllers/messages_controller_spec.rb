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

    it "create action should render js template and send email if user requests" do
      game = Factory(:game, :black_player => @user)
      game.opponent(@user).update_attribute(:email_on_message, true)
      Message.any_instance.stubs(:valid?).returns(true)
      post :create, :format => "js", :message => {:game_id => game.id}
      response.should render_template("create")
      assigns(:message).user == @user
      assigns(:message).game == game
      Notifications.deliveries.size.should == 1
      Notifications.deliveries.first.subject.should == "[Go vs Go] Chat from #{@user.username}"
    end

    it "should not send message email when user doesn't want it" do
      game = Factory(:game, :black_player => @user)
      game.opponent(@user).update_attribute(:email_on_message, false)
      Message.any_instance.stubs(:valid?).returns(true)
      post :create, :format => "js", :message => {:game_id => game.id}
      response.should be_success
      Notifications.deliveries.size.should == 0
    end
  end
end
