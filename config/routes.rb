Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:edit, :update]

  resources :test_cases do
    get :verify, on: :member
    get :download, on: :member
  end

  root 'home#index'
end
