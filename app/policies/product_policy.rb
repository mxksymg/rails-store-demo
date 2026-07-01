# Defines who can view, create, edit, and delete products
# Differentiates permissions for: admin (full access to all products, including unpublished ones), regular users and guests (access only to published products)
class ProductPolicy < ApplicationPolicy
  # Viewing the product list (GET /products) is allowed for everyone. Both authenticated users and guests can access the product list
  def index?
    true
  end
  # Viewing product details (GET /products/:id) is allowed for: admin (can view any product, including unpublished ones)
  # all other users (can view only published products)

  def show?
    # user&.admin? returns true for admins (full access), record.published? returns true if the product is published (public access)
    # When user is nil (not logged in), user&.admin? returns nil. In boolean logic, nil is treated as false
    # Therefore access depends only on record.published?
    user&.admin? || record.published?
  end
  # Creating a product (POST /products) is allowed only for admin
  def create?
    # user&.admin? returns true if user is admin. For guest or regular user it returns false
    # &. is Ruby's safe navigation operator. It prevents errors when calling a method on nil
    # If the object is nil, it returns nil instead of raising an error
    user&.admin?
  end
  # Updating a product (PATCH /products/:id) is allowed only for admin
  def update?
    user&.admin?
  end
  # Deleting a product (DELETE /products/:id) is allowed only for admin
  def destroy?
    user&.admin?
  end
  # class Scope < Scope - defines a new Scope class. It inherits from the parent ApplicationPolicy::Scope
  # The parent class provides: 1.initialize method that takes user, scope and stores them in @user and @scope
  # 2.a requirement to define resolve method otherwise it raises an error
  class Scope < Scope
    # def resolve - this is the main method of the Scope. When you call policy_scope(Product) in a controller, Pundit invokes this method
    # The result returned here is assigned to a controller variable (e.g. @products)
    def resolve
      if user&.admin?
        # scope represents the full collection of products, .all returns all products from the database
        # In result : admin can see all products in the list, both published (published: true) and unpublished (published: false)
        # This is required for full admin management in the panel
        scope.all
      else
        # scope.where(published: true) adds a condition to the query: "show only products where published is true"
        # In result : a regular user (even logged in) sees ONLY published products, unpublished products are hidden from the list
        scope.where(published: true)
      end
    end
  end
end
