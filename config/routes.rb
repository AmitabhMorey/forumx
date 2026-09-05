Rails.application.routes.draw do
  # Health status endpoint returning 200 OK and live diagnostics
  get "up" => "health#show", as: :rails_health_check

  # Devise Authentication
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Root & Public Pages
  root "home#index"

  get "/search", to: "search#index", as: :search
  get "/tags/:slug", to: "tags#show", as: :tag
  get "/users/:username", to: "users#show", as: :user_profile

  resources :categories, only: [:index, :show]

  resources :discussions do
    member do
      post :bookmark
      post :subscribe
      post :lock
      post :unlock
      post :pin
      post :unpin
    end

    resources :replies, only: [:create, :update, :destroy] do
      member do
        post :accept
      end
    end
  end

  # Voting for discussions and replies
  post "/votes/:voteable_type/:voteable_id/:value", to: "votes#create", as: :vote

  # Reports
  resources :reports, only: [:new, :create]

  # User Dashboard & Profile
  get "/dashboard", to: "dashboards#show", as: :dashboard
  get "/profile", to: "profiles#show", as: :profile
  get "/profile/edit", to: "profiles#edit", as: :edit_profile
  patch "/profile", to: "profiles#update", as: :update_profile
  get "/bookmarks", to: "bookmarks#index", as: :bookmarks
  get "/my-discussions", to: "dashboards#my_discussions", as: :my_discussions
  get "/my-replies", to: "dashboards#my_replies", as: :my_replies
  get "/settings", to: redirect("/users/edit"), as: :settings

  # Notifications
  resources :notifications, only: [:index, :update] do
    collection do
      post :mark_all_read
    end
  end

  # Administration & Moderation
  namespace :admin do
    get "/", to: "dashboard#index", as: :root
    get "/statistics", to: "dashboard#statistics", as: :statistics

    resources :users, only: [:index, :show, :update] do
      member do
        post :suspend
        post :unsuspend
        post :update_role
      end
    end

    resources :categories

    resources :discussions, only: [:index, :show, :destroy] do
      member do
        post :lock
        post :unlock
        post :pin
        post :unpin
        post :restore
      end
    end

    resources :replies, only: [:index, :destroy] do
      member do
        post :restore
      end
    end

    resources :reports, only: [:index, :show] do
      member do
        post :resolve
        post :dismiss
      end
    end

    resources :moderation_logs, only: [:index]
  end

  # Custom error pages
  match "/404", to: "errors#not_found", via: :all
  match "/403", to: "errors#forbidden", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
