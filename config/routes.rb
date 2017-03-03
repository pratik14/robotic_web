Rails.application.routes.draw do
  resources :test_cases do
    get :verify, on: :member
    get :download, on: :member
  end
end
