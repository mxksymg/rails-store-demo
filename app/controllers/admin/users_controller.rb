class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action -> { authorize :user, :admin_index? }

  def index
    @users = User.all.order(created_at: :desc)
  end
end
