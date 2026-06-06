require "test_helper"

class ProductImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:one)
    sign_in @user
  end
  test "should get create" do
    get product_images_create_path
    assert_redirected_to products_path
  end

  test "should get destroy" do
    get product_images_destroy_path
    assert_redirected_to products_path
  end
end
