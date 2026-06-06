# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    # Zwraca ścieżkę, na którą użytkownik ma zostać przekierowany po rejestracji
    products_path
  end
end
