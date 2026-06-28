# Controller for current user dashboard
# Shows list of products liked by current user
class DashboardController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Display user dashboard (home page) | GET /dashboard
  def index
    # Assigns @favorite_products with products liked by current user, favorite_products is defined in User model (has_many :through association)
    # Returns a collection of Product objects
    @favorite_products = current_user.favorite_products
  end
end
