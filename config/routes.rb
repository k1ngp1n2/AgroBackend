Rails.application.routes.draw do
  scope :api do
    post 'login' => 'user_token#create'
    devise_for :users, defaults: { format: :json }

    # PUBLIC

    # Pages
    resources :pages

    # Categories
    resources :categories, only: [:index, :show] do
      resources :products, only: :index
    end

    # Products
    resources :products

    # Farmers
    resources :farmers, only: :show do
      resources :products, only: :index
    end

    # Carts
    resources :carts, only: %i[show create update]


    # CLIENT


    # FARMER





  end
end
