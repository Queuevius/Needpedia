require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  get 'how_tos/index'
  post '/rate' => 'rater#create', :as => 'rate'
  namespace :master_admin do
    resources :settings
    resources :preformatted_messages
    resources :how_tos
    resources :questions
    resources :questionnaires
    resources :faqs
    resources :home_videos
    resources :admin_notifications
    resources :post_tokens
    resources :token_ans_debates
    resources :connections
    resources :user_gigs
    resources :flags
    # resources :likes
    resources :comments
    resources :gigs
    resources :answers do
      get 'approve_user'
    end
    resources :posts do
      collection do
        get 'private_posts'
      end
    end
    resources :users do
      collection do
        delete 'bulk_delete'
        get 'send_confirmation_link'
        get 'unconfirmed_users'
      end
    end
    resources :announcements
    resources :notifications
    resources :feedbacks
    # resources :services

    root to: "users#index"
  end

  namespace :admin do
    resources :post_tokens
    resources :token_ans_debates
    resources :connections
    resources :user_gigs
    resources :flags
    resources :comments
    resources :gigs
    resources :answers do
      get 'approve_user'
    end
    resources :posts do
      collection do
        get 'private_posts'
      end
    end
    resources :users do
      collection do
        delete 'bulk_delete'
        get 'send_confirmation_link'
        get 'unconfirmed_users'
      end
    end
    resources :notifications
    resources :feedbacks

    root to: "users#index"
  end
  get '/nuclear_note', to: 'nuclear_note#index'
  get '/privacy', to: 'home#privacy'
  get '/time_bank', to: 'home#time_bank'
  get '/terms', to: 'home#terms'
  get '/about_us', to: 'home#about_us'
  get '/contact_us', to: 'home#contact_us'
  get '/faq', to: 'home#faq'
  get '/chat', to: 'home#chat'
  get '/wall', to: 'profile#wall'
  get '/friends', to: 'profile#friends'
  get '/feed', to: 'profile#feed'
  get '/pictures', to: 'profile#pictures'
  get '/modal_picture', to: 'profile#modal_picture'
  get '/tracking', to: 'profile#tracking'
  get '/debate_tokens', to: 'profile#debate_tokens'
  get '/question_tokens', to: 'profile#question_tokens'
  get '/note_tokens', to: 'profile#note_tokens'
  get '/about', to: 'profile#about'
  get '/add_details', to: 'profile#add_details'
  get '/add_pictures', to: 'profile#add_pictures'
  get '/get_users', to: 'profile#get_users'
  get '/profile_image', to: 'profile#profile_image'
  patch '/update_profile_image', to: 'profile#update_profile_image'
  post '/create_pictures', to: 'profile#create_pictures'
  get '/search_results', to: 'profile#search_results'
  patch '/update_details', to: 'profile#update_details'
  patch '/change_rating', to: 'ratings#change_rating'
  get 'connections' => 'profile#my_connections'
  get 'friend_request' => 'profile#friend_request'
  post 'block_user' => 'profile#block_user'
  delete 'unblock_user' => 'profile#unblock_user'
  delete 'un_friend/:uuid' => 'profile#un_friend', as: 'un_friend'
  get 'tags/:tag' => 'posts#index', as: :tag
  authenticate :user, lambda {|u| u.admin? || u.master_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end


  resources :notifications, only: [:index]
  resources :announcements, only: [:index]

  resources :connection_requests, except: [:edit, :update, :show, :destroy]
  resources :connection_requests, only: [:index]
  scope :connection_requests do
    get 'accept/:uuid' => 'connection_requests#accept', as: 'accept_invitation'
    delete 'reject/:uuid' => 'connection_requests#reject', as: 'reject_invitation'
  end

  resources :connections

  resources :posts do
    resources :comments do
      delete 'remove_comment'
      patch :inappropriate
    end
    get 'layers'
    get 'problems'
    get 'ideas'
    get 'map'
    delete 'remove_private_user'
    delete 'remove_curated_user'
    patch 'track_post'
    collection do
      delete 'destroy_activity'
      get 'modal'
      get 'search_result'
      get 'all_areas'
      get 'all_layers'
      get 'all_problems'
      get 'all_ideas'
      get 'have'
      get 'want'
      get 'geo_maxing_posts'
    end
  end

  resources :comments
  resources :activities, only: [:index]

  resources :flags do
    collection do
      get 'reason_modal'
    end
    end

  resources :post_tokens do
    collection do
      get 'token_modal'
      get 'note'
      get 'debate'
      get 'question'
    end
  end

  resources :token_ans_debates

  resources :shares

  resources :likes do
    collection do
      get 'unlike'
      patch 'upvote'
      patch 'downvote'
    end
  end

  # resources :ratings, only: [:create] do
  #   patch 'change_rating'
  # end

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

  resources :conversations do
    collection do
      get 'users'
      get 'back'
    end
  end
  resources :messages do
    patch 'read'
  end

  resources :feedbacks, only: [:new, :create]

  # resources :profiles do
  #   member do
  #     get 'wall'
  #     get 'friends'
  #     get 'pictures'
  #     get 'about'
  #     get 'add_details'
  #   end
  #   collection do
  #     patch 'update_details'
  #   end
  # end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks", :sessions => "users/sessions", registrations: 'users/registrations'}
  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
