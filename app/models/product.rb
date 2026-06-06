class Product < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  has_many :cart_items, dependent: :destroy   # dodaj
  has_many :order_items, dependent: :destroy  # dodaj
  has_many_attached :images
  has_one_attached :cover_image
end
