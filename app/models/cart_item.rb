# Model representing an item in the shopping cart
# Connects Cart with Product and stores product quantity
# Each record in cart_items represents one product added to the cart
class CartItem < ApplicationRecord
  # Each CartItem belongs to one Cart
  # Requires cart_id foreign key in cart_items table and you can access cart via cart_item.cart
  belongs_to :cart
  # Each CartItem belongs to one Product
  # Requires product_id foreign key in cart_items table and you can access product via cart_item.product
  belongs_to :product
  # Validate that quantity is a number greater than 0
  # Prevents adding products with zero or negative quantity, 'numericality' validates that value is a number (not nil by default)
  validates :quantity, numericality: { greater_than: 0 }
end
