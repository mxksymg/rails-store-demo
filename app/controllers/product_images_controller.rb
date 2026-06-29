# Controller for managing product images
# Supports uploading (single or multiple) and deleting images and uses Active Storage for file storage
class ProductImagesController < ApplicationController
  before_action :authenticate_user!
  # Run set_product before each action
  before_action :set_product
  # Check if current user is an admin
  before_action :authorize_admin!
  # Add new images to product gallery | POST /products/:product_id/images
  def create
    # Check if image files were uploaded, params[:images] contains an array of uploaded files
    if params[:images].present?
      # If images are present, attach them to product using Active Storage, @product.images.attach adds new files without removing existing ones
      @product.images.attach(params[:images])
      redirect_to edit_product_path(@product), notice: "Zdjęcia zostały dodane."
    else
      redirect_to edit_product_path(@product), alert: "Nie wybrano żadnych zdjęć."
    end
  end
  # Remove a single image from product gallery | DELETE /products/:product_id/images/:id
  def destroy
    # Find specific attached image in product images by ID from URL params
    # @product.images.find(params[:id]) searches Active Storage attachments
    image = @product.images.find(params[:id])
    # Delete file from storage, 'purge' removes attachment and related Active Storage records permanently
    # 'purge_later' for background deletion instead of immediate removal
    image.purge
    redirect_to edit_product_path(@product), notice: "Zdjęcie usunięte."
  end

  private
  # Find product by ID from URL params, raises ActiveRecord::RecordNotFound (404) if product doesn't exist
  def set_product
    @product = Product.find(params[:product_id])
  end
  # Check if current user has admin flag (admin: true), redirect to home page with warning message if not admin
  def authorize_admin!
    redirect_to root_path, alert: "Brak uprawnień" unless current_user.admin?
  end
end
