# Base controller for the entire application, all other controllers inherit from this class
# Provides shared features: Pundit authorization, CSRF protection, and error handling
class ApplicationController < ActionController::Base
  # Include Pundit module for authorization
  # Makes authorize and policy_scope available in all controllers
  include Pundit::Authorization
  # CSRF protection (Cross-Site Request Forgery)
  # Requires valid token for POST, PUT, PATCH, DELETE requests, raises ActionController::InvalidAuthenticityToken if token is invalid
  protect_from_forgery with: :exception
  # Handle ActiveRecord::RecordNotFound exception, redirects to record_not_found method when record is not found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  # Handle Pundit authorization error (user not authorized), catches exception and redirects to user_not_authorized method
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
  # Handle "record not found" (404)
  def record_not_found
    # sets flash message and redirects to products list
    flash[:alert] = "Produkt nie istnieje."
    redirect_to products_path
  end
  # Handle authorization error (no permissions)
  def user_not_authorized
    # Sets flash message and redirects back or to root if no referrer
    flash[:alert] = "Nie masz uprawnień do wyświetlenia tego produktu."
    redirect_to(request.referrer || root_path)
  end
end
