class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  # presense - needs to be filled
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "Możesz wystawić tylko jedną recenzję dla tego produktu" }
end
