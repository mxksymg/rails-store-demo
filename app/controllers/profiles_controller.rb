# Controller for managing user profile (personal data, address, phone), allows editing and updating profile information
class ProfilesController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # Show profile edit form (personal data, address, phone) | GET /profile/edit
  def edit
    # Assign current logged-in user to variable (Devise helper current_user)
    @user = current_user
    # No Pundit authorization needed because each user can only edit their own profile
  end
  # Update current user's profile data | PATCH /profile
  def update
    @user = current_user
    # Attempt to update user with permitted user_params
    if @user.update(user_params)
      # :pending_order flag - is set in OrdersController#create when user tries to place order, but lacks address data and then redirected to profile edit
      if session[:pending_order]
        # If there is a pending order, remove the flag from session
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
  # Defines permitted parameters for profile update, protects against mass assignment attacks (strong parameters)
  def user_params
    # Requires :user key in params (e.g. user: { first_name: "Jan" })
    params.require(:user).permit(:first_name, :last_name, :street, :city, :postal_code, :phone)
  end
end
