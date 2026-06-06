class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  attribute :status, :string, default: "nowe"

  def add_product(product_id, quantity = 1)
    cart_item = cart_items.find_or_initialize_by(product_id: product_id)
    cart_item.quantity ||= 0
    cart_item.quantity += quantity
    cart_item.save
  end

  def remove_product(product_id)
    cart_item = cart_items.find_by(product_id: product_id)
    cart_item.destroy if cart_item
  end

  def total_price
    cart_items.sum { |item| item.quantity * item.product.price }
  end
end
