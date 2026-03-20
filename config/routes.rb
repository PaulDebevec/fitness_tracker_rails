Rails.application.routes.draw do
  root "home#index"

  resources :profiles do
    resources :check_ins, only: [:index]
  end
end
