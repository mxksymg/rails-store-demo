class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = current_user.cart
    if @cart.cart_items.empty?
      redirect_to products_path, alert: "Koszyk jest pusty"
    end
  end

  def create
  @cart = current_user.cart
  if current_user.street.blank? || current_user.city.blank? || current_user.postal_code.blank? || current_user.phone.blank?
    session[:pending_order] = true
    redirect_to edit_profile_path, alert: "Przed złożeniem zamówienia uzupełnij adres i numer telefonu."
    return
  end
  puts ">>> CREATE: koszyk istnieje? #{@cart.inspect}"
  puts ">>> CREATE: cart_items: #{@cart.cart_items.inspect}"
  @order = current_user.orders.new(total: @cart.total_price, status: "pending")
  if @order.save
    puts ">>> CREATE: zamówienie zapisane, ID=#{@order.id}"
    @cart.cart_items.each do |item|
      @order.order_items.create(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end
    @cart.cart_items.destroy_all
    puts ">>> CREATE: przekierowuję do demo_payment_path(#{@order.id})"
    redirect_to demo_payment_path(@order), notice: "Zamówienie utworzone. Przejdź do płatności demo."
  else
    puts ">>> CREATE: BŁĄD zapisu – #{@order.errors.full_messages}"
    render :new
  end
end

  def show
    @order = current_user.orders.find(params[:id])
    authorize @order
  end

  def demo_payment
    @order = current_user.orders.find(params[:order_id])
    @order.update(status: "paid", paid_at: Time.current)
    redirect_to order_path(@order), notice: "Płatność symulowana (BLIK demo) – zamówienie opłacone!"
  end
end
