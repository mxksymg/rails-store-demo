# Model representing a user's shopping cart
# Stores products via CartItem and calculates total price, each user has one cart
# Cart has many cart_items which are removed when cart is destroyed
class Cart < ApplicationRecord
  # Each cart belongs to one User
  # Requires user_id foreign key in carts table and you can access user via cart.user
  belongs_to :user
  # Cart has many CartItems, when cart is destroyed, all associated CartItems are also destroyed (cascade delete)
  # dependent: :destroy ensures data consistency and prevents from having unauthorized records
  has_many :cart_items, dependent: :destroy
  # Cart has many products through CartItem, allows access to products via cart.products
  # This is a (has_many :through) association using a join model. Cart is connected to Product through CartItem. Cart has no direct foreign key to Product
  # Instead, CartItem stores the product and links it to the cart (e.g. cart = Cart.first    cart.products => returns all products in the cart)
  has_many :products, through: :cart_items
  # Sets default value for status attribute to "new" and is used to track cart state (e.g. "new", "ordered", "abandoned")
  attribute :status, :string, default: "nowe"
  # Adds a product to the cart or increases quantity if it already exists. Params: (product_id: ID of the product to add, quantity: amount to add (default 1)
  def add_product(product_id, quantity = 1)
    # Finds or creates a CartItem for this product in the cart, if it doesn't exist, initializes a new one (find_or_initialize_by)
    cart_item = cart_items.find_or_initialize_by(product_id: product_id)
    # If quantity is nil, set it to 0 (safety check to prevent errors)
    cart_item.quantity ||= 0
    # Increases quantity by the given amount
    cart_item.quantity += quantity
    # Saves changes to the database (if validations pass)
    cart_item.save
  end
  # Removes a product from the cart. Params: (product_id: ID of the product to remove)
  def remove_product(product_id)
    # cart_items is a collection of all items in the cart (Cart has_many :cart_items), find_by(product_id: product_id) searches for a cart item with matching product_id
    # Returns CartItem if found, returns nil if not found
    cart_item = cart_items.find_by(product_id: product_id)
    # If cart_item is not nil, destroy it
    cart_item.destroy if cart_item
  end
  # Calculates total cart value (sum of all product prices multiplied by quantity)
  # def total_price
  # .sum {} - iterates over a collection and accumulates results into a single value
  # |item| is a block parameter that represents each element in the collection
  # item.quantity returns the quantity attribute from the CartItem object
  # item.product accesses the Product associated with this CartItem via belongs_to :product, .price retrieves the price attribute from that Product
  # cart_items.sum { |item| item.quantity * item.product.price }
  # end
  # When calling cart_items.sum { ... }, rails loads all cart_items first, then for each item it accesses product.price
  # Each access triggers a separate database query (N+1 query problem)
  def total_price
    # includes(:product) eager loads all associated products in a single query
    cart_items.includes(:product).sum { |item| item.quantity * item.product.price }
  end
end
