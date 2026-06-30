# Model representing a review (opinion) written by a user about a product
# Connects User and Product and stores rating and comment
class Review < ApplicationRecord
  # Each review belongs to one user, requires user_id column in reviews table and you can access user via review.user
  belongs_to :user
  # Each review belongs to one product, requires product_id column in reviews table and you can access product via review.product
  belongs_to :product
  # Rating validation: must be present and between 1 and 5 and ensures only values 1, 2, 3, 4, 5 are allowed
  # Prevents invalid input like 0, 6, or non-numeric values
  validates :rating, presence: true, inclusion: { in: 1..5 }
  # Comment is optional, but if present must be at most 1000 characters long, length: { maximum: 1000 } restricts the text length
  # no presence validation means comment can be blank
  validates :comment, length: { maximum: 1000 }
  # Ensures uniqueness of the (user_id, product_id) pair, user can only write one review per product
  # uniqueness: { scope: :product_id } enforces this rule
  # message allows custom error message instead of default Rails message
  validates :user_id, uniqueness: { scope: :product_id, message: "Możesz wystawić tylko jedną recenzję dla tego produktu" }
end
