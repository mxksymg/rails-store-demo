# Admin controller for managing orders.
# Supports listing all orders, viewing details, and updating order status.
class Admin::OrdersController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Display list of all orders (for admin). GET /admin/orders
  def index
    # Verify if current user has permission to view the order list.
    # The :admin_index? method is defined in OrderPolicy.
    authorize :order, :admin_index?
    # Load all orders, sorted by newest first.
    @orders = Order.all.order(created_at: :desc)
  end
  # Display details of a single order (for admin). GET /admin/orders/:id
  def show
    # Find order by ID from the URL. If not found, raises ActiveRecord::RecordNotFound (404).
    @order = Order.find(params[:id])
    # Verify if current user has permission to view this specific order.
    # The :admin_show? method is defined in OrderPolicy.
    authorize @order, :admin_show?
  end
  # Update order status (for admin). PATCH /admin/orders/:id
  def update
    # Find order by ID from the URL.
    @order = Order.find(params[:id])
    # Verify if current user has permission to update orders (not specific record).
    # The :admin_update? method is defined in OrderPolicy.
    authorize :order, :admin_update?
    # Attempt to update the order with permitted parameters.
    # `order_params` (private method) filters and allows only :status.
    if @order.update(order_params)
      # Redirect to order list with success message.
      redirect_to admin_orders_path, notice: "Status zamówienia zaktualizowany."
    else
      # Redirect to order list with error message.
      redirect_to admin_orders_path, alert: "Nie udało się zaktualizować statusu."
    end
  end
  private
  # Define permitted parameters for order update
  # Prevents mass assignment of sensitive fields (e.g. :id, :user_id)
  def order_params
    # Allows only for status parameter
    params.require(:order).permit(:status)
  end
end
