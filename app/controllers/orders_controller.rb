# Controller for managing orders placed by logged-in users
# Allows : viewing user orders list, creating new order from cart contents, showing order details, simulating payment (demo BLIK)
class OrdersController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Display current user's orders list | GET /orders
  def index
    # Load current user's orders sorted by newest first
    @orders = current_user.orders.order(created_at: :desc)
    # No Pundit authorization needed, user only sees their own orders, so no data leakage risk
  end
  # Show new order form (order summary page) | GET /orders/new
  def new
    # Fetch current user's cart
    @cart = current_user.cart
    # Check if cart is empty, redirect to products list with warning message if empty
    if @cart.cart_items.empty? || @cart.nil?
      redirect_to products_path, alert: "Koszyk jest pusty"
    end
  end
  # Create a new order from cart contents | POST /orders
  def create
    # Fetch current user's cart
    @cart = current_user.cart
    # Check if user profile has all required fields filled, if missing data, store pending order in session, redirect to profile edit with message and stop execution
    if current_user.street.blank? || current_user.city.blank? || current_user.postal_code.blank? || current_user.phone.blank?
      session[:pending_order] = true
      redirect_to edit_profile_path, alert: "Przed złożeniem zamówienia uzupełnij adres i numer telefonu."
      return
    end
    # Useful for tracking cart state during order creation process
    # puts ">>> CREATE: koszyk istnieje? #{@cart.inspect}"
    # puts ">>> CREATE: cart_items: #{@cart.cart_items.inspect}"
    # Create new Order for current user, sets total from cart and status to "pending"
    # new does not persist to DB, only builds the object
    @order = current_user.orders.new(total: @cart.total_price, status: "pending")
    # Attempt to save order to database
    if @order.save
      # If save succeeds, log new order ID to console
      # puts ">>> CREATE: zamówienie zapisane, ID=#{@order.id}"
      # Iterate through each cart product and create corresponding OrderItem records, copies product, quantity, and price at the time of purchase
      @cart.cart_items.each do |item|
        @order.order_items.create(
          product: item.product,
          quantity: item.quantity,
          price: item.product.price
        )
      end
      # Clear cart after moving products to order (remove all items)
      @cart.cart_items.destroy_all
      # puts ">>> CREATE: przekierowuję do demo_payment_path(#{@order.id})"
      redirect_to demo_payment_path(@order), notice: "Zamówienie utworzone. Przejdź do płatności demo."
    else
      # puts ">>> CREATE: BŁĄD zapisu – #{@order.errors.full_messages}"
      # render :new
    end
  end
  # Display a single order details | GET /orders/:id
  def show
    # Find order belonging to current user by ID, raises ActiveRecord::RecordNotFound if not found or not owned by user
    @order = current_user.orders.find(params[:id])
    # checks if user can view this order, OrderPolicy#show?
    authorize @order
  end
  # Simulate payment (demo BLIK), updates order status to "paid" | GET /demo_payment/:order_id
  def demo_payment
    # Find order belonging to current user by order_id
    @order = current_user.orders.find(params[:order_id])
    # Update order status to "paid" and set payment timestamp
    @order.update(status: "paid", paid_at: Time.current)
    redirect_to order_path(@order), notice: "Płatność symulowana (BLIK demo) – zamówienie opłacone!"
  end
end
