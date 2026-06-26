# Controller for managing the current user's shopping cart
# Allows viewing, adding/removing products, and clearing the cart
class CartsController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Display current user's shopping cart contents | GET /cart
  def show
    # Fetch current user's cart, create one if it doesn't exist
    # current_user.cart || current_user.create_cart ensures cart is always available
    @cart = current_user.cart || current_user.create_cart
    # Load all cart items with associated products
    # In SQL procceded this two querys : SELECT * FROM cart_items WHERE cart_id = 1
    # SELECT * FROM products WHERE id IN (...) - loads all products in one query (avoids N+1 problem)
    @cart_items = @cart.cart_items.includes(:product)
  end
  # Add product to current user's cart | POST /cart/add/:product_id
  def add
    # Fetch or create cart (same logic as above)
    @cart = current_user.cart || current_user.create_cart
    # Find product by ID from URL params
    product = Product.find(params[:product_id])
    # Checks if user can view this product (published or admin), uses ProductPolicy#show? (user.admin? || record.published?)
    # Raises exception if not authorized
    authorize product, :show?
    # Add product to cart (defined in Cart model)
    @cart.add_product(product.id)
    # Redirect to cart page with success message
    redirect_to cart_path, notice: "#{product.name} dodany do koszyka"
end
  # Remove product from current user's cart | DELETE /cart/remove/:product_id
  def remove
    # Fetch cart (assumes it already exists for logged-in user)
    @cart = current_user.cart
    # Find product by ID
    product = Product.find(params[:product_id])
    # Remove product from cart (defined in Cart model)
    @cart.remove_product(product.id)
    # Redirect to cart page with success message
    redirect_to cart_path, notice: "#{product.name} usunięty z koszyka"
  end
  # Clear entire cart (remove all items) | DELETE /cart
  def destroy
    # Fetch current user's cart
    @cart = current_user.cart
    # Delete all cart items and persist changes, destroy_all runs callbacks on each CartItem (runs X - SELECT qureys instead of one)
    @cart.cart_items.destroy_all
    # Redirect to cart page with success message
    redirect_to cart_path, notice: "Koszyk wyczyszczony"
  end
end
