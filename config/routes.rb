Rails.application.routes.draw do
  root "restaurants#index"

  resources :restaurants, only: [:index, :show]

  namespace :api do
    namespace :v1 do
      resources :device_reports, only: [:create]
      resources :restaurants, only: [:index, :show]
    end
  end
end