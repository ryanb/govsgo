require 'spec_helper'

describe MovesController do
  it "should add a move and respond with javascript" do
    post 'create'
    response.should be_success
  end
end
