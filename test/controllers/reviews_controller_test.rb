require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "user@example.com", password: "password")
    @admin = User.create!(email: "admin@example.com", password: "password", admin: true)
    @product = Product.create!(name: "Test", price: 10, published: true)
    sign_in @user
  end

  test "should create review" do
    assert_difference("Review.count", 1) do
      post product_reviews_path(@product), params: { review: { rating: 5, comment: "Super!" } }
    end
    assert_redirected_to @product
    assert_equal "Dziękujemy za ocenę!", flash[:notice]
  end

  test "should not create review without rating" do
    assert_no_difference("Review.count") do
      post product_reviews_path(@product), params: { review: { rating: nil, comment: "test" } }
    end
    assert_redirected_to @product
    assert_not flash[:alert].blank?
  end

  test "non-authenticated user cannot create review" do
    sign_out @user
    post product_reviews_path(@product), params: { review: { rating: 5 } }
    assert_redirected_to new_user_session_path
  end

  test "user can update own review" do
    review = @user.reviews.create!(rating: 3, comment: "Ok", product: @product)
    patch product_review_path(@product, review), params: { review: { rating: 4, comment: "Better" } }
    assert_redirected_to @product
    assert_equal "Recenzja zaktualizowana.", flash[:notice]
    review.reload
    assert_equal 4, review.rating
    assert_equal "Better", review.comment
  end

  test "user cannot update other user's review" do
    other_user = User.create!(email: "other@example.com", password: "password")
    review = other_user.reviews.create!(rating: 5, comment: "Great", product: @product)
    patch product_review_path(@product, review), params: { review: { rating: 1 } }
    assert_redirected_to root_path
    assert_equal "Nie masz uprawnień do wyświetlenia tego produktu.", flash[:alert]
  end

  test "admin can delete any review" do
    sign_out @user
    sign_in @admin
    review = @user.reviews.create!(rating: 5, comment: "Nice", product: @product)
    assert_difference("Review.count", -1) do
      delete product_review_path(@product, review)
    end
    assert_redirected_to @product
    assert_equal "Recenzja usunięta.", flash[:notice]
  end

  test "user can delete own review" do
    review = @user.reviews.create!(rating: 5, comment: "Nice", product: @product)
    assert_difference("Review.count", -1) do
      delete product_review_path(@product, review)
    end
    assert_redirected_to @product
  end
end
