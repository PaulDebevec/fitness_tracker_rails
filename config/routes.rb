Rails.application.routes.draw do
  root "home#index"

  resources :profiles, only: [:new, :create] do
    resources :check_ins, only: [:index]
  end
end
