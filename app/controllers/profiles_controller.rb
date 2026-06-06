class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      if session[:pending_order]
        session.delete(:pending_order)
        redirect_to checkout_path, notice: "Dane zapisane. Możesz teraz złożyć zamówienie."
      else
        redirect_to edit_profile_path, notice: "Dane zaktualizowane."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :street, :city, :postal_code, :phone)
  end
end
