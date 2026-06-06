class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: [ :update, :destroy ]
  before_action :authorize_review!, only: [ :update, :destroy ]

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user
    authorize @review

    if @review.save
      redirect_to @product, notice: "Dziękujemy za ocenę!"
    else
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end

  def update
    if @review.update(review_params)
      redirect_to @product, notice: "Recenzja zaktualizowana."
    else
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review.destroy
    redirect_to @product, notice: "Recenzja usunięta."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def authorize_review!
    authorize @review
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
