class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite_products = current_user.favorite_products
  end
end
