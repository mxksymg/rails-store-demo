# Model representing a product in the store
# Stores product data: name, description, price, category, publish status
# Has relationships with favorites, cart_items, order_items, reviews, and attachments (images)
# Central entity of the application that other models are built around
class Product < ApplicationRecord
  # Product can be liked by many users
  # dependent: :destroy ensures all associated favorites are removed when the product is deleted
  has_many :favorites, dependent: :destroy
  # Indirect association to users who liked the product
  # through: :favorites and source: :user allows access to users via favorites product.favorited_by returns users who favorited this product
  has_many :favorited_by, through: :favorites, source: :user
  # Product can appear in many carts through CartItem
  # dependent: :destroy removes all cart items containing this product, when product is deleted, carts are cleaned from this product
  has_many :cart_items, dependent: :nullify
  # Product can appear in many orders
  # !WARNING! dependent: :destroy is not good approach here, deleting a product will also delete all related OrderItems, which results in loss of order history
  # In real life examples it's usually better to avoid deleting products physically or use dependent: :nullify instead
  # or make belongs_to :product optional in OrderItem
  # Current behavior: product deletion removes related order items
  # has_many :cart_items, dependent: :destroy
  # has_many :cart_items, dependent: :nullify - prevents loss of OrderItem records, order history is preserved
  # Avoids foreign key violation errors if db has constraints without ON DELETE SET NULL
  # However: does not preserve product details (name, description, category) after deletion
  # If OrderItem does not store product name, order history may show nil or "Product unavailable", which is not ideal for production.
  has_many :order_items, dependent: :destroy
  # Product can have many images (e.g. different views, color variants)
  # has_many_attached allows attaching multiple files to the model and you can access it via product.images
  has_many_attached :images
  # Single main product image (e.g. for product listing display)
  # has_one_attached allows only one file attachment and you can access it via product.cover_image
  has_one_attached :cover_image
  # When a product is deleted, all its reviews (opinions) are also removed from the database
  has_many :reviews, dependent: :destroy
end
