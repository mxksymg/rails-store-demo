class UserPolicy < ApplicationPolicy
  def admin_index?
    user.admin?
  end
end
