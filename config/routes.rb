# frozen_string_literal: true

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
        get '/users/profile/view', to: 'users#profile'
        resources :volunteers, only: %i[index show accept reject]
        get '/volunteers/orders', to: 'volunteers#orders_volunteers'
        resources :helpees, only: %i[index show]
        resources :document_types, only: %i[index]
        resources :categories, only: %i[index show]
        resources :orders, only: %i[create index show destroy]
        resources :ratings, only: %i[create]
        get '/orders/show/all', to: 'orders#show_status'
        get '/orders/show/map', to: 'orders#orders_on_map'
        get '/orders/show/helpee', to: 'orders#helpee_orders'
        get '/orders/show/volunteers', to: 'orders#order_volunteers'
        get '/orders/show/volunteer', to: 'orders#volunteer_orders'
        post '/orders/accept', to: 'orders#accept_volunteer'
        post '/orders/take', to: 'orders#take_order'
        post '/orders/status', to: 'orders#update_status'
        resources :notifications, only: %i[index]
        post '/notifications/seen', to: 'notifications#seen'
        get '/notifications/index_not_seen', to: 'notifications#index_not_seen'
        post '/helpees/ratingPending', to: 'helpees#rating_pending'
        post '/helpees/rating', to: 'helpees#rating'
        post '/volunteers/ratingPending', to: 'volunteers#rating_pending'
        post '/volunteers/rating', to: 'volunteers#rating'
      end
    end
  end

  mount ActionCable.server => '/cable'

  devise_for :admin_users, ActiveAdmin::Devise.config
  get '/admin', to: redirect('/admin/login')
  ActiveAdmin.routes(self)
end
