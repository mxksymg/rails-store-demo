class OrderPolicy < ApplicationPolicy
  # Dla panelu admina – lista wszystkich zamówień
  def admin_index?
    user.admin?
  end

  def admin_show?
    user.admin?
  end

  def admin_update?
    user.admin?
  end

  # Dla zwykłego użytkownika – tylko jego zamówienia
  def index?
    user.present?
  end

  def show?
    user.admin? || record.user_id == user.id
  end

  def create?
    user.present?
  end
end
