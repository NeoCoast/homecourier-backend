Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations sessions passwords]
  devise_for :helpee, :volunteer, skip: %i[registrations sessions passwords]

  defaults formats: :json do
    namespace :api do
      namespace :v1 do
        devise_scope :user do
          post '/users/login', to: 'devise/sessions#create'
          delete '/users/logout', to: 'devise/sessions#destroy'
        end

        devise_scope :helpee do
          post '/helpees/signup', to: 'devise/helpees/registrations#create'
        end

        devise_scope :volunteer do
          post '/volunteers/signup', to: 'devise/volunteers/registrations#create'
        end

        resources :users, only: %i[index]
        resources :volunteers, only: %i[index]
        resources :helpees, only: %i[index]
      end
    end
  end
end
