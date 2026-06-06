class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user&.admin? || record.published?
  end

  def create?
    user&.admin?   # <- dodaj &.
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?   # <- dodaj &.
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
end
