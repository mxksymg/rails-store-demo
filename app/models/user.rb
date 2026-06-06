class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  # validates :email, uniqueness: { message: "Adres email został już wykorzystany" }

  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy

  after_create :create_user_cart
  after_initialize :set_default_admin, if: :new_record?

  def favorited?(product)
    favorites.exists?(product: product)
  end

  private

  def create_user_cart
    Cart.create(user: self)
  end

  def set_default_admin
    self.admin = false if admin.nil?
  end
end
