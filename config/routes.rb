Rails.application.routes.draw do
  get "product_images/create"
  get "product_images/destroy"
  get "profiles/edit"
  get "profiles/update"
    get "orders/new"
    get "orders/create"
    get "orders/show"
    get "carts/show"
  devise_for :users, controllers: { registrations: "users/registrations" }

  namespace :admin do
    resources :orders, only: [ :index, :update, :show ]
    resources :users, only: [ :index ]
  end

  resource :profile, only: [ :edit, :update ]

  resources :products do
    resource :favorite, only: [ :create, :destroy ]  # to wystarczy
    resources :images, only: [ :create, :destroy ], controller: "product_images"
  end

  resource :cart, only: [ :show, :destroy ] do
    post "add/:product_id", to: "carts#add", as: :add
    delete "remove/:product_id", to: "carts#remove", as: :remove
  end

  resources :orders, only: [ :index, :create, :show ]
  get "checkout", to: "orders#new"
  get "demo_payment/:order_id", to: "orders#demo_payment", as: :demo_payment

  get "dashboard", to: "dashboard#index"
  get "up" => "rails/health#show", as: :rails_health_check
  root "products#index"
end
