# Admin controller for listing users
class Admin::UsersController < ApplicationController
  # Ensures user is signed in before any action.
  before_action :authenticate_user!
  # before_action block runs before every action
  # If authorization fails, raises Pundit::NotAuthorizedError handled in ApplicationController (redirect with "not authorized" message)
  before_action do
    authorize :user, :admin_index?
  end
  # list all users GET /admin/users
  def index
    # Load all users sorted by newest first
    @users = User.all.order(created_at: :desc)
    # No explicit authorize here because it's handled by before_action above
  end
end
