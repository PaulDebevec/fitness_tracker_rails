Rails.application.routes.draw do
  root "home#index"

  resources :profiles do
    resources :check_ins
  end
end
