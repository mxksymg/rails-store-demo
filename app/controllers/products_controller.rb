class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = policy_scope(Product)
    if params[:categories].present?
      @products = @products.where(category: params[:categories].keys)
    end
  end

  def show
    authorize @product
  end

  def new
    @product = Product.new
    authorize @product
  end

  def edit
    authorize @product
  end


def create
  @product = Product.new(product_params.except(:cover_image))
  authorize @product
  if @product.save
    @product.cover_image.attach(params[:product][:cover_image]) if params[:product][:cover_image].present?
    redirect_to @product, notice: "Produkt utworzony."
  else
    render :new, status: :unprocessable_entity
  end
end

def update
  authorize @product
  if @product.update(product_params.except(:cover_image))
    if params[:product][:cover_image].present?
      @product.cover_image.purge if @product.cover_image.attached?
      @product.cover_image.attach(params[:product][:cover_image])
    end
    redirect_to @product, notice: "Produkt zaktualizowany."
  else
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    authorize @product
    @product.destroy
    redirect_to products_path, notice: "Produkt został usunięty."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :published, :category, :cover_image, images: [])
  end
end
