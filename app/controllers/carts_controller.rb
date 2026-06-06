class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_user.cart || current_user.create_cart
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add
    @cart = current_user.cart || current_user.create_cart
    product = Product.find(params[:product_id])
    authorize product, :show?
    @cart.add_product(product.id)
    redirect_to cart_path, notice: "#{product.name} dodany do koszyka"
end

  def remove
    @cart = current_user.cart
    product = Product.find(params[:product_id])
    @cart.remove_product(product.id)
    redirect_to cart_path, notice: "#{product.name} usunięty z koszyka"
  end

  def destroy
    @cart = current_user.cart
    @cart.cart_items.destroy_all
    redirect_to cart_path, notice: "Koszyk wyczyszczony"
  end
end
