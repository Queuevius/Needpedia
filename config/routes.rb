require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    resources :user_gigs
    resources :flags
    resources :comments
    resources :gigs
    resources :posts
    resources :users
    resources :announcements
    resources :notifications
    # resources :services

    root to: "users#index"
  end
  get '/privacy', to: 'home#privacy'
  get '/time_bank', to: 'home#time_bank'
  get '/terms', to: 'home#terms'
  authenticate :user, lambda {|u| u.admin?} do
    mount Sidekiq::Web => '/sidekiq'
  end


  resources :notifications, only: [:index]
  resources :announcements, only: [:index]
  resources :posts do
    get 'layers'
    get 'problems'
    get 'proposals'
    get 'ideas'
    collection do
      get 'search_result'
      get 'all_areas'
      get 'all_layers'
      get 'all_problems'
      get 'all_proposals'
      get 'all_ideas'
    end
  end

  resources :comments

  resources :flags do
    collection do
      get 'reason_modal'
    end
  end

  resources :gigs do
    put 'disable'
    collection do
      get 'my_accepted'
      get 'search'
      get 'search_result'
      put 'accept'
    end
  end
  resources :transactions, only: [:create] do
    collection do
      get 'award'
    end
  end
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
