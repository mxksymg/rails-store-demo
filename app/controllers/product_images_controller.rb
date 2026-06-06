class ProductImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :authorize_admin!

  def create
    if params[:images].present?
      @product.images.attach(params[:images])
      redirect_to edit_product_path(@product), notice: "Zdjęcia zostały dodane."
    else
      redirect_to edit_product_path(@product), alert: "Nie wybrano żadnych zdjęć."
    end
  end

  def destroy
    image = @product.images.find(params[:id])
    image.purge
    redirect_to edit_product_path(@product), notice: "Zdjęcie usunięte."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def authorize_admin!
    redirect_to root_path, alert: "Brak uprawnień" unless current_user.admin?
  end
end
