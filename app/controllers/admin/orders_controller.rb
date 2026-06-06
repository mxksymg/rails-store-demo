class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :order, :admin_index?
    @orders = Order.all.order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
    authorize @order, :admin_show?
  end

  def update
    @order = Order.find(params[:id])
    authorize :order, :admin_update?
    if @order.update(order_params)
      redirect_to admin_orders_path, notice: "Status zamówienia zaktualizowany."
    else
      redirect_to admin_orders_path, alert: "Nie udało się zaktualizować statusu."
    end
  end

  private

  def order_params
    params.require(:order).permit(:status)
  end
end
