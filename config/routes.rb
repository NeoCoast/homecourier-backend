Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations sessions passwords confirmations]
  devise_for :helpee, :volunteer, skip: %i[registrations sessions passwords confirmations]

  defaults formats: :json do
    namespace :api do
      namespace :v1 do
        devise_scope :user do
          post '/users/login', to: 'devise/sessions#create'
          delete '/users/logout', to: 'devise/sessions#destroy'
          get '/users/confirmation', to: 'devise/confirmations#show'
          post '/users/password', to: 'devise/passwords#create'
          get '/users/password', to: 'devise/passwords#edit'
          put '/users/password', to: 'devise/passwords#update'
        end

        devise_scope :helpee do
          post '/helpees/signup', to: 'devise/helpees/registrations#create'
        end

        devise_scope :volunteer do
          post '/volunteers/signup', to: 'devise/volunteers/registrations#create'
        end

        resources :users, only: %i[index]
        resources :volunteers, only: %i[index show]
        resources :helpees, only: %i[index show]
        resources :document_types, only: %i[index]
        resources :categories, only: %i[create index show destroy]
        resources :orders, only: %i[create index show destroy]
        get '/orders/show/all', to: 'orders#show_status'
        post '/orders/take', to: 'orders#take_order'
        resources :notifications, only: %i[index]
        post '/notifications/seen', to: 'notifications#seen'
      end
    end
  end

  mount ActionCable.server => '/cable'
end
