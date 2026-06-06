class ApplicationController < ActionController::Base
  include Pundit::Authorization
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def record_not_found
    flash[:alert] = "Produkt nie istnieje."
    redirect_to products_path
  end

  def user_not_authorized
    flash[:alert] = "Nie masz uprawnień do wyświetlenia tego produktu."
    redirect_to(request.referrer || root_path)
  end
end
