class ReviewPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    user.present? && (user.admin? || record.user_id == user.id)
  end

  def destroy?
    user.present? && (user.admin? || record.user_id == user.id)
  end
end
