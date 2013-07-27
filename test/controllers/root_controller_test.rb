require 'test_helper'

class RootControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get breakout" do
    get :breakout
    assert_response :success
  end

end
