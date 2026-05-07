Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'home#index'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  patch '/settings/appearance', to: 'settings#update_appearance', as: :settings_appearance
  get '/sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }

  resource :email_verification, only: [:create]
  get 'email_verification/:token', to: 'email_verifications#show', as: :verify_email

  resources :password_resets, only: %i[new create edit update], param: :token
  resource :settings, only: %i[edit update]
  resources :users, only: [:destroy]
  resources :profiles, except: %i[new create] do
    resource :report, only: [:show]
    resources :check_ins do
      member do
        delete :remove_photo
      end

      resources :measurements
    end
  end
end
