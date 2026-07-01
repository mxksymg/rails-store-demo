# Policy for product reviews (opinions). Defines who can create, edit, and delete reviews
# Reviews are created by logged-in users for specific products. Editing and deleting is limited to the review author or admin
class ReviewPolicy < ApplicationPolicy
  # Determines whether a user can create a new review (POST /products/:product_id/reviews). Any logged-in user is allowed, regardless of role
  def create?
    # user.present? checks if the user is authenticated
    user.present?
    # We do not check if the user already wrote a review, because this is handled by uniqueness validation in the Review model
  end
  # Determines whether a user can update an existing review (PATCH /products/:product_id/reviews/:id)
  def update?
    # user.present? - user must be also logged in, user.admin? - can edit any review, record.user_id == user.id - review author
    user.present? && (user.admin? || record.user_id == user.id)
  end
  # Determines whether a user can delete a review (DELETE /products/:product_id/reviews/:id). Same rules as update?
  # Deletion is permanent (record is removed from the database)
  def destroy?
    user.present? && (user.admin? || record.user_id == user.id)
  end
  # No index? and show? methods are defined because reviews do not have their own index or show pages
  # They are displayed in the context of a product (products/show). Author information is shown only within the product view

  # No Scope class is needed. There is no separate page that shows all reviews of all products across the entire application
  # Instead, reviews are always displayed in a specific context which naturally limits the collection being shown
  # Scope is used when you need to filter the entire collection of a model's objects (e.g. all reviews) before displaying them in a list
end
