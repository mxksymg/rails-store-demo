require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @user = users(:one)
    sign_in @user
    # before every test deletes all products
    Product.destroy_all
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


test "should filter by price range" do
    Product.delete_all
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    medium = Product.create!(name: "Średni", price: 50, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { min_price: 30, max_price: 80 }
    assert_response :success

    assert_select "h2", text: /Średni/
    assert_select "h2", text: /Tani/, count: 0
    assert_select "h2", text: /Drogi/, count: 0
  end

  test "should sort by price ascending" do
    Product.delete_all
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { sort: "price_asc" }
    assert_response :success
    # checks the displaying order on website
    # :first-child - finds first element on list and checks if matches <h2> "Tani"
    assert_select "div.grid div:first-child h2", text: /Tani/
    assert_select "div.grid div:last-child h2", text: /Drogi/
  end

  test "should sort by price descending" do
    Product.delete_all
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { sort: "price_desc" }
    assert_response :success

    assert_select "div.grid div:first-child h2", text: /Drogi/
    assert_select "div.grid div:last-child h2", text: /Tani/
  end

  test "should combine price filter and sorting" do
    Product.delete_all
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    medium = Product.create!(name: "Średni", price: 50, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { min_price: 40, max_price: 150, sort: "price_asc" }
    assert_response :success

    assert_select "div.grid h2", count: 2
    assert_select "div.grid div:first-child h2", text: /Średni/
    assert_select "div.grid div:last-child h2", text: /Drogi/
    assert_select "div.grid div h2", text: /Tani/, count: 0
  end
end
