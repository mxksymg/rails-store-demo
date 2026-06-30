# Model representing a single order line item
# Connects Order with Product and stores what was ordered
# Includes product, quantity, and price at time of purchase
class OrderItem < ApplicationRecord
  # Each order item belongs to one order. Requires order_id column in order_items table and you can access order via order_item.order
  belongs_to :order
  # Each order item belongs to one product. Requires product_id column in order_items table and you can access product via order_item.product
  # Product can be deleted from the database, but OrderItem remains to preserve order history
  belongs_to :product
end
