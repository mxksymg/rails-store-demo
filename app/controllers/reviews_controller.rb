# Controller for managing product reviews (opinions)
# Allows : creating a new review for a product (logged-in users only), editing own review, deleting own review (or any review if user is admin)
class ReviewsController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: [ :update, :destroy ]
  # Runs authorize_review! before update and destroy actions, calls Pundit authorize @review to check permissions
  # Ensures user can edit or delete this specific review
  before_action :authorize_review!, only: [ :update, :destroy ]
  # Create a new review for a product (logged-in user only) | POST /products/:product_id/reviews
  def create
    # Build a new review associated with @product using form parameters
    # build is similar to new, but automatically sets product_id to @product.id
    @review = @product.reviews.build(review_params)
    # Assign current user as the author of the review, this ensures we know who wrote the opinion
    @review.user = current_user
    # Pundit authorization: checks if current user can create a review, reviewPolicy#create? should return true if user is logged in
    authorize @review
    # Attempt to save review to database
    if @review.save
      redirect_to @product, notice: "Dziękujemy za ocenę!"
    else
      # If save fails (e.g. validation errors like missing rating or too long comment), redirect to product page with error messages
      # full_messages.to_sentence joins all errors into a readable sentence
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end
  # Update existing review (only author or admin) | PATCH /products/:product_id/reviews/:id
  def update
    # Attempt to update review using permitted review_params, @review is already set by set_review before action
    if @review.update(review_params)
      redirect_to @product, notice: "Recenzja zaktualizowana."
    else
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end
  # Delete review (only author or admin) | DELETE /products/:product_id/reviews/:id
  def destroy
    @review.destroy
    redirect_to @product, notice: "Recenzja usunięta."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    # .reviews returns collection of all reviews belonging to this product, .find(params[:id]) searches for a review by ID within that collection
    # (e.g. /products/5/reviews/12)
    @review = @product.reviews.find(params[:id])
  end

  def authorize_review!
    # authorize checks if current user can perform action on this object (update/destroy) based on ReviewPolicy
    # If not authorized, Pundit raises NotAuthorizedError
    authorize @review
  end
  # Defines permitted parameters for review, protects against mass assignment attacks (strong parameters)
  def review_params
    # Requires :review key in params, only permits :rating and :comment attributes
    params.require(:review).permit(:rating, :comment)
  end
end
