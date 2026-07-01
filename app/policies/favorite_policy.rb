# Policy for favorites, defines who can add and remove product likes. Favorites are user-managed so any user can like a product
# but only the owner of the favorite (or admin) can remove it
# There is no separate page listing all favorites (e.g. /favorites) that would show likes from all users.
# Instead, favorites are displayed within other views. Thats why we do not define index? or show?
class FavoritePolicy < ApplicationPolicy
  # Any logged-in user can like a product. We do not check if the user already liked the product here,
  # because it is handled by model validation in Favorite (uniqueness of user_id and product_id)
  def create?
    # user.present? ensures the user is authenticated (any role)
    user.present?
  end
  # Only the owner of the favorite can delete it.  Admin has no special privileges here, cannot delete others favorites.
  # If admin should be allowed, we could use: user.admin? ||

  # Current rule: users can only manage their own favorites
  def destroy?
    # record.user_id == user.id checks if current user owns the favorite
    user.present? && record.user_id == user.id
  end
  # No Scope is needed. There is no requirement to filter the collection of favorites, because they are always accessed in the context of a product or current_user
end
