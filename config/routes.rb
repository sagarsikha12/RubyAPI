Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      delete 'notificaitons/clearall', to:'notifications#clearall'
      get 'campaigns/listall', to: 'campaigns#listall'
      get 'check-session', to: 'sessions#check_session'
      # config/routes.rb
      get '/csrf_token', to: 'sessions#csrf_token'

      # config/routes.rb
      get 'users/current', to: 'users#current'
      post '/change-password', to: 'users#update_password'

      delete 'logout', to: 'sessions#destroy'

      delete 'campaigns/:id', to: 'campaigns#destroy', as: 'delete_campaign'
      post 'login', to: 'sessions#create'
      get 'mycampaign', to: 'campaigns#my_campaigns'
      post 'mycampaign', to: 'campaigns#my_campaigns'

      resources :users, only: [:index, :destroy] do
        member do
          delete :destroy
          patch :make_admin
        end
      end
      resources :campaigns, only: [:index,:update,:create]
      resources :categories, only: [:index, :show, :create, :update, :destroy]

      resources :notifications, only: [:index, :update,:delete,:destroy]
      delete 'notifications', to:'notifications#destroy'

        # Devise routes under api/v1
        devise_for :users, controllers: {
          registrations: 'api/v1/users/registrations',
          sessions: 'api/v1/users/sessions',
          passwords: 'api/v1/users/passwords'
        }
      devise_scope :user do
        post 'register', to: 'users/registrations#create'
        post 'passwords', to: 'users/passwords#create'    # For sending reset password instructions
        get 'passwords/edit', to: 'users/passwords#edit'  # For rendering the reset password form (might be handled by the frontend)
        put 'passwords', to: 'users/passwords#update'     # For submitting the new password

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
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  get '/api/user_signed_in', to: 'application#user_signed_in'


  get '/api/current_user_data', to: 'application#current_user_data'


  mount ActionCable.server => '/cable'


  root "campaigns#index"
end
