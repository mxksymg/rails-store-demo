# Controller for managing product likes (favorites) by user
# Allows adding and removing products from favorites list
class FavoritesController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Add product to current user's favorites | POST /products/:product_id/favorite
  def create
    # Find product by ID from URL params, raises ActiveRecord::RecordNotFound (404) if not found
    @product = Product.find(params[:product_id])
    # Use build to create object first, then check authorization (authorize @favorite) and only then save (@favorite.save)
    # Using create would persist record before authorization, which could allow unauthorized database writes
    # `build` creates a new object in memory (not saved to database), automatically sets user_id to current_user.id
    @favorite = current_user.favorites.build(product: @product)
    # Pundit authorization: checks if current user can create a favorite, calls create? in FavoritePolicy; raises exception if not permitted
    authorize @favorite
    if @favorite.save
      # fallback_location defines default redirect path (products list), used when previous page cannot be determined
      redirect_back(fallback_location: products_path, notice: "Dodano do polubionych")
    else
      redirect_to product_path(@product), alert: "Nie udało się dodać"
    end
  end
  # Remove product from current user's favorites | DELETE /products/:product_id/favorite
  def destroy
    # Find favorite belonging to current user for given product, returns nil if not found
    @favorite = current_user.favorites.find_by(product_id: params[:product_id])
    # Pundit authorization: checks if user can delete this favorite, authorize @favorite if @favorite (skip if nil to avoid error)
    authorize @favorite if @favorite
    # Check if favorite exists (was found)
    if @favorite
      # Remove favorite from database (calls destroy on record)
      @favorite.destroy
      redirect_back(fallback_location: products_path, notice: "Usunięto z polubionych")
    else
      redirect_to product_path(params[:product_id]), alert: "Nie znaleziono polubienia"
    end
  end
end
