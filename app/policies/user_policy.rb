# Policy for users. Defines who can view the list of users. Currently is very simple, only admin can view all users in the admin panel
class UserPolicy < ApplicationPolicy
  # Determines whether an admin can view the list of all users (GET /admin/users). Used in Admin::UsersController#index for authorization
  def admin_index?
    # user.admin? checks if the current user has admin flag set to true
    user.admin?
    # No other methods (index?, show?, create?, update?, destroy?) are defined because regular users do not have access to user management
    # There is no public users list page for non-admin users. No Scope class is needed because only admins can see all users
    # and regular users never access the full collection
  end
end
