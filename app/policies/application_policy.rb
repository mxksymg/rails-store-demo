# Base class for all authorization policies in the application
# Defines default rules (everything denied) and provides helper methods, all other policies (e.g. ProductPolicy, OrderPolicy) inherit from this class
class ApplicationPolicy
  # Insted of typing def user @user end | def record @record end use attr_reader
  # attr_reader :user, :record creates getter methods for @user and @record
  # Allows child policies to use user and record instead of @user and @record. Its publicly defined because we use it in views or testing
  attr_reader :user, :record
  # Initialize is the policy's entry point
  # Receives the current user and target record, then stores them so other policy methods can use them for authorization
  def initialize(user, record)
    @user = user
    @record = record
  end

  # All methods return false by default EVERYTHING IS DENIED
  # This is a safe approach. Missing rules in child policies won't grant access instead of accidentally allowing it
  # Each child policy (e.g. ProductPolicy) overrides these methods to define specific permissions for each model

  # Determines whether the user can view a list of resources (e.g. /products)
  def index?
    false
  end
  # Determines whether the user can view a single resource's details (e.g. /products/1)
  def show?
    false
  end
  # Determines whether the user can create a new resource (e.g. POST /products)
  def create?
    false
  end
  # new? does not contain its own logic it simply returns the same result as create?
  # If user can create a product (create? returns true), they can also access the form (new? returns true)
  # If user cannot create a product (create? returns false), they should not see the form (new? returns false)
  def new?
    create?
  end
  # Determines whether the user can update a resource (e.g. PATCH /products/1)
  def update?
    false
  end
  # Determines whether the user can view the edit form (GET /products/1/edit)
  # By default it delegates to update?. If user can update, they can access the edit form. Same logic as in new?
  def edit?
    update?
  end
  # Determines whether the user can delete a resource (e.g. DELETE /products/1)
  def destroy?
    false
  end
  # Scope is an inner class in a policy (e.g. ProductPolicy::Scope)
  # It defines which records in a collection should be visible to a user, initialize works like in ApplicationPolicy
  # It receives two arguments and stores them in instance variables
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    # resolve method must be defined in each child policy scope
    # Returns a filtered collection (e.g. only published products) and if not overridden, it raises an exception as a safety mechanism
    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private
    # attr_reader :user, :scope creates getter methods for @user and @scope. This allows using user and scope without the @ symbol inside resolve
    # user and scope are used only inside the resolve method to compute the filtered collection. They are implementation details and are not intended
    # to be accessed outside the Scope object, thats why its private method
    attr_reader :user, :scope
  end
end
