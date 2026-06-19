require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get edit" do
    get edit_profile_path
    assert_response :success
  end

  test "should update profile" do
    patch profile_path, params: {
      user: {
        name: "Nowe imię"
      }
    }

    assert_response :redirect
  end

   test "should filter by price range" do
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
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { sort: "price_desc" }
    assert_response :success

    assert_select "div.grid div:first-child h2", text: /Drogi/
    assert_select "div.grid div:last-child h2", text: /Tani/
  end

  test "should combine price filter and sorting" do
    cheap = Product.create!(name: "Tani", price: 10, published: true)
    medium = Product.create!(name: "Średni", price: 50, published: true)
    expensive = Product.create!(name: "Drogi", price: 100, published: true)

    get products_path, params: { min_price: 40, max_price: 150, sort: "price_asc" }
    assert_response :success

    assert_select "div.grid div", count: 2
    assert_select "div.grid div:first-child h2", text: /Średni/
    assert_select "div.grid div:last-child h2", text: /Drogi/
    assert_select "div.grid div h2", text: /Tani/, count: 0
  end
end
