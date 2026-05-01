Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root "home#index"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  patch "/settings/appearance", to: "settings#update_appearance", as: :settings_appearance
  get "/sitemap.xml", to: "sitemap#index", defaults: { format: "xml" }

  resource :email_verification, only: [:create]
  get "email_verification/:token", to: "email_verifications#show", as: :verify_email

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token
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
