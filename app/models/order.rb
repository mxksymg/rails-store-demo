# Model representing an order placed by a user
# Stores total price, status (e.g. "pending", "paid"), and timestamps
class Order < ApplicationRecord
  # Each order belongs to one user. Requires user_id column in orders table and you can access user via order.user
  belongs_to :user
  # Order has many OrderItems
  # dependent: :destroy removes all associated order items when order is deleted
  has_many :order_items, dependent: :destroy
  # Calculates total order value based on its order items
  def total_price
    # For each OrderItem, multiplies quantity by the stored unit price and sums all results across items
    # Uses item.price (frozen price in OrderItem), not item.product.price, so order value stays consistent even if product price changes later
    order_items.sum { |item| item.quantity * item.price }
  end
end
