Rails.application.routes.draw do
  defaults formats: :json do
    namespace :api do
      namespace :v1 do
        resources :orders, only: [:create, :index, :show, :destroy]
          resources :categories, only: [:create, :index, :show, :destroy], shallow: true
      end
    end
  end

  devise_for :users, skip: %i[registrations sessions passwords]
  devise_scope :user do
    post '/signup', to: 'registrations#create'
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'

    defaults formats: :json do
      namespace :api do
        namespace :v1 do
          resources :users, only: [:index]
        end
      end
    end
  end
end
