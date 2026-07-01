# Policy for orders - defines who can view, create, update, and access orders
# Differentiates permissions for: admin (full access to all orders in admin panel), regular user (access only to their own orders),
# unauthenticated user (no access to orders)
# The application has two order contexts: Admin::OrdersController - manages all orders, OrdersController - manages current user's orders
class OrderPolicy < ApplicationPolicy
  # Determines whether an admin can view a list of all orders (GET /admin/orders)
  def admin_index?
    user.admin?
  end
  # Determines whether an admin can view details of any order (GET /admin/orders/:id)
  def admin_show?
    user.admin?
  end
  # Determines whether an admin can update the status of any order (PATCH /admin/orders/:id)
  def admin_update?
    user.admin?
  end

  # Determines whether a logged-in user can view their own orders list (GET /orders). Only authenticated users can access their orders
  def index?
    user.present?
  end
  # Determines whether a user can view a specific order (GET /orders/:id)
  def show?
    # Allowed for: admin (can view any order), order owner (checks record.user_id == user.id)
    user.admin? || record.user_id == user.id
  end
  # Determines whether a user can create a new order (POST /orders). Only authenticated users are allowed to place orders
  def create?
    user.present?
  end
  # update? is not defined in this policy, because regular users are not allowed to modify orders
  # order status is only changed by admin or payment system
  # No Scope class is defined. In OrdersController#index we use current_user.orders, so the collection is already limited to the current user
  # In Admin::OrdersController#index we use Order.all, because authorization is handled via authorize :order, :admin_index? rather than via Scope
end
