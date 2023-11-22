Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      get 'check-session', to: 'sessions#check_session'
      # config/routes.rb
      get '/csrf_token', to: 'sessions#csrf_token'

      # config/routes.rb
      get 'users/current', to: 'users#current'

      delete 'logout', to: 'sessions#destroy'

      delete 'campaigns/:id', to: 'campaigns#destroy', as: 'delete_campaign'
      post 'login', to: 'sessions#create'
      get 'mycampaign', to: 'campaigns#my_campaigns'
      post 'mycampaign', to: 'campaigns#my_campaigns'

      resources :campaigns, only: [:index,:update,:create]
      resources :categories, only: [:index, :show, :create, :update, :destroy]

      resources :notifications, only: [:index, :update,:delete,:destroy]
      delete 'notifications', to:'notifications#destroy'

      devise_scope :user do
        post 'register', to: 'users/registrations#create'
      end
      post '/images', to: 'images#create'

      resources :users


    end
  end

  # config/routes.rb

namespace :admin do
  resources :campaigns, only: [:index] do
    member do
      patch :approve
      patch :reject
    end
  end
end




  resources :categories
  resources :campaigns do
    collection do
      get 'my_campaigns'
    end
  end




  resources :notifications, only: [:update]
  get '/notifications', to: 'notifications#index'


  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'

  }
  get '/api/user_signed_in', to: 'application#user_signed_in'


  get '/api/current_user_data', to: 'application#current_user_data'


  mount ActionCable.server => '/cable'


  root "campaigns#index"
end
