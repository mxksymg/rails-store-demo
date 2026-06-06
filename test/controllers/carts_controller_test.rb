require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers



  test "should get show" do
    user = users(:one)
    sign_in user

    get cart_path
    assert_response :success
  end
end
