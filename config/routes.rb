require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      match '/auth/sign_in', to: 'auth#options_request', via: [:options]
      mount_devise_token_auth_for 'User', at: 'auth'
      match '/register_device', to: 'device_registration#register_device', via: [:post]
      resources :faqs, only: [:index]
      resources :how_to, only: [:index]
      resources :posts, only: [:index, :create]
      resources :chat_threads do
        collection do
          get :current
          post :set_current
        end
      end
    end
  end
  resources :tasks
  put 'posts/:id/api_update', to: 'posts#api_update_post', as: 'api_update_post'
  resources :topics
  get '/search_users_modal', to: 'groups#search_users_modal'
  resources :groups do
    resources :topics do
      delete 'remove_topic'
    end
    patch 'update_default_group', on: :collection
    member do
      post 'join', to: 'groups#join'
      post 'request_to_join', to: 'groups#request_to_join'
      post 'accept_request/:request_id', to: 'groups#accept_request', as: 'accept_request'
      delete 'reject_request/:request_id', to: 'groups#reject_request', as: 'reject_request'
      delete 'leave_group', to: 'groups#leave_group'
      post '/groups/:group_id/invite/:user_id', to: 'groups#invite_user', as: 'invite_user_to_group'
      get 'group_notifications', to: 'groups#group_notifications'
      delete 'reject_invitation/:invitation_id', to: 'groups#reject_invitation', as: 'reject_invitation'
      post 'accept_invitation/:invitation_id', to: 'groups#accept_invitation', as: 'accept_invitation'
    end
  end
  resources :interested_users
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  get 'how_tos/index'
  post '/rate' => 'rater#create', :as => 'rate'
  namespace :master_admin do
    get 'user_ai_histories/show'
    resources :admin_notices
    resources :user_assistant_documents
    resources :settings
    resources :admin_histories
    resources :preformatted_messages
    resources :how_tos
    resources :impacts
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
      collection do
        delete 'bulk_delete'
        delete :all_delete, action: :destroy_all
      end
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
    resources :tutorials
    resources :announcements
    resources :notifications
    resources :feedbacks
    resources :deletions
    # resources :services

    root to: "users#index"
  end

  namespace :admin do
    resources :blocked_ips do
      member do
        delete :unblock
      end
    end
    resources :button_images
    resources :email_templates
    resources :post_tokens
    resources :token_ans_debates
    resources :connections
    resources :user_gigs
    resources :flags do
      delete 'flags/:flag_id', to: 'flags#delete_flagable', as: 'delete_flag'
    end
    resources :comments
    resources :gigs
    resources :banned_terms
    resources :answers do
      collection do
        delete 'bulk_delete'
        delete :all_delete, action: :destroy_all
      end
      get 'approve_user'
    end
    resources :posts do
      collection do
        get 'private_posts'
        get 'deleted_posts'
        get 'restore_deleted_posts'
        post 'upload'
      end
    end
    resources :users do
      patch 'comment_user', on: :member
      member do
        get :user_history
      end
      collection do
        delete 'bulk_delete'
        get 'send_confirmation_link'
        get 'unconfirmed_users'
      end
      post :create_admin_history_log, on: :member
    end
    resources :notifications
    resources :feedbacks
    resources :deletions
    resources :deletion_requests do
      post 'delete_post_version/:version_id', action: :delete_post_version, as: :delete_post_version
    end
    resources :post_versions
    resources :groups
    resources :invitations
    resources :membership
    resources :request


    root to: "users#index"
  end
  get '/otp', to: 'profile#otp'
  get '/ai', to: 'home#chatbot'
  get '/user_tutorials', to: 'profile#tutorials'
  get '/nuclear_note', to: 'nuclear_note#index'
  get '/privacy', to: 'home#privacy'
  get '/time_bank', to: 'home#time_bank'
  get '/terms', to: 'home#terms'
  get '/about_us', to: 'home#about_us'
  get '/contact_us', to: 'home#contact_us'
  get '/faq', to: 'home#faq'
  get '/careers', to: 'home#careers'
  get '/pdf', to: 'user_assistant_documents#pdf_file'
  get '/pdf_links', to: 'user_assistant_documents#pdf_links'
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
  authenticate :user, lambda {|u| u.admin? || u.master_admin?} do
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
    resources :objectives do
      delete 'remove_objective'
    end
    resources :related_contents do
      delete 'remove_content'
    end
    resources :interested_users do
      delete 'remove_interested_user'
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
    delete 'delete_image_attachment'
    resources :post_versions, only: [] do
      member do
        post 'restore', to: 'post_versions#restore'
        post 'report', to: 'post_versions#report'
        post 'request_delete', to: 'post_versions#request_delete'
      end
    end
  end
  resources :comments
  resources :related_contents
  resources :objectives
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
  get 'enable_otp_show_qr', to: 'users#enable_otp_show_qr', as: 'enable_otp_show_qr'
  post 'enable_otp_verify', to: 'users#enable_otp_verify', as: 'enable_otp_verify'

  get 'users/otp', to: 'users#show_otp', as: 'user_otp'
  post 'users/otp', to: 'users#verify_otp', as: 'verify_user_otp'
  post 'verify_backup_code', to: 'users#verify_backup_code'
  post 'verify_backup_code_show_qrcode', to: 'users#verify_backup_code_show_qrcode', as: 'verify_backup_code_show_qrcode'

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

  get 'otp_verifications/new', to: 'otp_verifications#new', as: :new_otp_verification
  post 'otp_verifications', to: 'otp_verifications#create', as: :verify_otp

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks", :sessions => "users/sessions", registrations: 'users/registrations'}
  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/user_tutorials/update_viewed', to: 'user_tutorials#update_viewed', as: 'update_viewed'
end
