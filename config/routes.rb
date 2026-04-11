Rails.application.routes.draw do
  root "home#index"

  resources :profiles do
    resource :report, only: [:show]
    resources :check_ins do
      member do
        delete :remove_photo
      end
      
      resources :measurements
    end
  end
end
