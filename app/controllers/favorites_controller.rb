class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @favorite = current_user.favorites.build(product: @product)
    authorize @favorite          # ← dodaj
    if @favorite.save
      redirect_back(fallback_location: products_path, notice: "Dodano do polubionych")
    else
      redirect_to product_path(@product), alert: "Nie udało się dodać"
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by(product_id: params[:product_id])
    authorize @favorite if @favorite   # ← dodaj
    if @favorite
      @product = @favorite.product
      @favorite.destroy
      redirect_back(fallback_location: products_path, notice: "Usunięto z polubionych")
    else
      redirect_to product_path(params[:product_id]), alert: "Nie znaleziono polubienia"
    end
  end
end
