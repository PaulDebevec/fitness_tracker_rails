Rails.application.routes.draw do
  constraints(host: "bodmetriks.com") do
    get "*path", to: redirect { |params, req|
      "https://bodimetrix.com/#{params[:path]}"
    }
  end
  root "home#index"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  patch "/settings/appearance", to: "settings#update_appearance", as: :settings_appearance
  get "/sitemap.xml", to: "sitemap#index", defaults: { format: "xml" }

  resource :settings, only: [:edit, :update]
  resources :users, only: [:destroy]
  resources :profiles, except: [:new, :create] do
    resource :report, only: [:show]
    resources :check_ins do
      member do
        delete :remove_photo
      end
      
      resources :measurements
    end
  end
end
