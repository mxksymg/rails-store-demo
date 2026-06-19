class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = policy_scope(Product)
    # category filtering
    if params[:categories].present?
      @products = @products.where(category: params[:categories].keys)
    end

    # search bar, in app/views/products/index.html.erb :query is name of a text-field(seach bar)
    if params[:query].present?
      # ? - is a SQL placeholder for parameterized queries (prevents SQL injection)
      @products = @products.where("name LIKE ? OR description LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    # price range filtering (from/to)
    min_price = params[:min_price].to_f if params[:min_price].present?
    max_price = params[:max_price].to_f if params[:max_price].present?

    if min_price && max_price && min_price > max_price
      # changing place
      min_price, max_price = max_price, min_price
    end

    if min_price
      @products = @products.where("price >= ?", min_price)
    end
    if max_price
      @products = @products.where("price <= ?", max_price)
    end


    case params[:sort]
    when "price_asc"
      @products = @products.order(price: :asc)
    when "price_desc"
      @products = @products.order(price: :desc)
    else
      @products = @products.order(created_at: :desc)
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
