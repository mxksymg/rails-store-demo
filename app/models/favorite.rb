# Model representing a user's favorite (like) of a product
# Connects User and Product, each record means a user liked a product
# This is a join model enabling a many-to-many relationship between users and products through favorites
class Favorite < ApplicationRecord
  # Each favorite belongs to one user. Requires user_id column in favorites table and you can access user via favorite.user
  belongs_to :user
  # Each favorite belongs to one product. Requires product_id column in favorites table and you can access product via favorite.product
  belongs_to :product
end
