require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:one)
    sign_in @user
  end
  test "should get create" do
    post product_favorite_path(@product)
    assert_response :redirect
  end

  test "should get destroy" do
    delete product_favorite_path(@product)
    assert_response :redirect
  end
end
