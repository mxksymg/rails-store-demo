# Model representing an application user
# Handles authentication (Devise), personal data storage and relationships with cart, orders, favorites, and reviews
class User < ApplicationRecord
  # Devise modules handling authentication features: database_authenticatable - password-based authentication stored in DB
  # registerable - allows user registration,  recoverable - enables password reset via email
  # rememberable - stores user session via cookies, validatable - adds validations for email and password
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # This line is commented out because Devise already adds email uniqueness validation with a default English message
  # If you want a custom message, you can uncomment and customize it, but it may conflict with Devise's built-in validation
  # validates :email, uniqueness: { message: "Adres email został już wykorzystany" }

  # User can like many products
  # dependent: :destroy ensures all user's favorites are removed when the user is deleted
  has_many :favorites, dependent: :destroy
  # Indirect association to products liked by the user
  # through: :favorites and source: :product allows access via favorites, user.favorite_products returns products liked by the user
  has_many :favorite_products, through: :favorites, source: :product
  # Each user has only one cart
  # dependent: :destroy ensures the cart is removed when the user is deleted
  has_one :cart, dependent: :destroy
  # User can have many orders
  # dependent: :destroy ensures orders are deleted when user is removed
  has_many :orders, dependent: :destroy
  # User can write many product reviews
  # dependent: :destroy ensures reviews are deleted when user is removed
  has_many :reviews, dependent: :destroy

  # After creating a new user (after_create), a cart is automatically created for them
  # This ensures every user always has a cart ready to use (no need to check for nil)
  after_create :create_user_cart
  # After initializing a new record (after_initialize), if it's a new record (if: :new_record?), set default admin value to false if it's nil
  # Ensures new users are not admins unless explicitly set to true
  after_initialize :set_default_admin, if: :new_record?

  # Checks if the user has liked a given product and returns true if a favorite exists for the product
  # Used in views to show correct button ("Like" or "Unlike")
  def favorited?(product)
    favorites.exists?(product: product)
  end

  private

  # Creates a cart for a new user. Triggered by after_create callback
  # Ensures the cart exists immediately after registration
  def create_user_cart
    # self refers to the current object where the method is called
    # This allows the new cart to be linked to this specific user (cart.user_id = self.id)
    Cart.create(user: self)
  end

  # Sets default admin value to false if it is nil
  # Triggered by after_initialize callback only for new records
  def set_default_admin
    self.admin = false if admin.nil?
  end
end
