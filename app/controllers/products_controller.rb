# Main controller for managing products in the store
# Supports filtering (category, price, search, sorting), showing product details, admin can only create, edit and delete actions
class ProductsController < ApplicationController
  # Run set_product before show, edit, update, and destroy actions, avoids repeating product lookup in each action
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  # Display list of products with filtering, sorting, and search | GET /products
  def index
    # Apply Pundit policy scope for Product model
    # Regular users see only published products, admins see all products (published and unpublished)
    @products = policy_scope(Product)
    # Check if categories are present in request params
    if params[:categories].present?
      # params[:categories] is a hash, e.g. { "bags" => "bags", "pads" => "pads" }, params[:categories].keys returns array of category names
      # where(category: ...) filters products by selected categories
      @products = @products.where(category: params[:categories].keys)
    end

    # search bar, in app/views/products/index.html.erb :query is name of a text-field(seach bar)
    if params[:query].present?
      # ? - is a SQL placeholder for parameterized queries (prevents SQL injection)
      @products = @products.where("name LIKE ? OR description LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    # price range filtering (from/to)
    # params[:min_price] - retrieves min_price parameter from URL query string (e.g. ?min_price=50), present? - Checks if object is not nil and not empty
    # to_f - Konwertuje wartość na liczbę zmiennoprzecinkową (float). (e.g. "50".to_f → 50.0)
    min_price = params[:min_price].to_f if params[:min_price].present?
    max_price = params[:max_price].to_f if params[:max_price].present?

    if min_price && max_price && min_price > max_price
      # changing place if user write in wrong order
      min_price, max_price = max_price, min_price
    end

    if min_price
      @products = @products.where("price >= ?", min_price)
    end
    if max_price
      @products = @products.where("price <= ?", max_price)
    end

    # Case statement checks the :sort parameter and sorts products accordingly
    # order(price: :asc) - sorts by price ascending (cheapest first), order(price: :desc) - sorts by price descending (most expensive first)
    # else - sorts by created_at descending (newest first)
    case params[:sort]
    when "price_asc"
      @products = @products.order(price: :asc)
    when "price_desc"
      @products = @products.order(price: :desc)
    else
      @products = @products.order(created_at: :desc)
    end
  end

  # Display single product details | GET /products/:id
  def show
    # authorize checks if current user can view this product, ProductPolicy#show? allows access if product is published or user is admin
    authorize @product
  end
  # Show form for creating a new product (admin only) | GET /products/new
  def new
    # Creates a new empty Product object in memory (not persisted to database)
    @product = Product.new
    # Pundit authorization: checks if user can create a new product, ProductPolicy#create? should return true only for admin users
    authorize @product
  end
  # Show form for editing an existing product (admin only) | GET /products/:id/edit
  def edit
    authorize @product
  end

# Create a new product in the database (admin only) | POST /products
def create
  # Create product with parameters but exclude :cover_image, product_params.except(:cover_image) removes cover_image from params
  @product = Product.new(product_params.except(:cover_image))
  authorize @product
  # Attempt to save product to database
  if @product.save
    # If save succeeds and cover image is provided, attach it to product
    # params[:product][:cover_image] is the uploaded file through form
    @product.cover_image.attach(params[:product][:cover_image]) if params[:product][:cover_image].present?
    redirect_to @product, notice: "Produkt utworzony."
  else
    # If save fails (e.g. validation errors), render new view, status: :unprocessable_entity sets HTTP 422 response with errors
    render :new, status: :unprocessable_entity
  end
end
# Update existing product (admin only) | PATCH/PUT /products/:id
def update
  authorize @product
  # Attempt to update product (excluding cover_image for safety)
  if @product.update(product_params.except(:cover_image))
    # If update succeeds and a new cover image is provided then
    if params[:product][:cover_image].present?
      # Delete old cover image if it exists (purge)
      @product.cover_image.purge if @product.cover_image.attached?
      # Attach new cover image
      @product.cover_image.attach(params[:product][:cover_image])
    end
    redirect_to @product, notice: "Produkt zaktualizowany."
  else
    render :edit, status: :unprocessable_entity
  end
end
  # Delete product from database (admin only) | DELETE /products/:id
  def destroy
    # Pundit authorization: checks if user can delete product
    authorize @product
    # Delete product from database (including dependent records via dependent: :destroy)
    @product.destroy
    redirect_to products_path, notice: "Produkt został usunięty."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
  # Defines permitted parameters for mass assignment (strong parameters), protects against mass assignment vulnerabilities
  def product_params
    # Permitted attributes for product strong parameters: name, description, price, published, category, cover_image, images
    # images: [] indicates an array (has_many_attached)
    # cover_image is permitted here but excluded in create/update via except
    params.require(:product).permit(:name, :description, :price, :published, :category, :cover_image, images: [])
  end
end
