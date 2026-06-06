require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @user = users(:one)
    sign_in @user
  end
  test "should get index" do
    get products_path
    assert_response :success
  end

  test "should get show" do
    get products_path(@product)
    assert_response :success
  end

  test "should search products by name" do
    product = Product.create!(name: "Torba skórzana", price: 100, published: true)
    Product.create!(name: "Plecak", price: 80, published: true)
    get products_path, params: { query: "Torba" }
    assert_response :success
    assert_select "h2", text: /Torba skórzana/
    assert_select "h2", text: /Plecak/, count: 0
  end

  test "should search products by description" do
    product = Product.create!(name: "Portfel", description: "Skórzany portfel", price: 50, published: true)
    Product.create!(name: "Pasek", description: "Skórzany pasek", price: 60, published: true)
    get products_path, params: { query: "portfel" }
    assert_response :success
    assert_select "h2", text: /Portfel/
    assert_select "h2", text: /Pasek/, count: 0
  end

test "search works with categories filter together" do
  product1 = Product.create!(name: "Torba", category: "torby", published: true)
  product2 = Product.create!(name: "Torba", category: "akcesoria", published: true)

  get products_path, params: { query: "Torba", categories: { torby: "torby" } }
  assert_response :success

  assert_select "h2", text: /Torba/, count: 1
  assert_select "h2", text: /Torba/, count: 1, msg: "Powinien być tylko jeden produkt z kategorii torby"
  assert_select "h2", text: /akcesoria/, count: 0
end
end
