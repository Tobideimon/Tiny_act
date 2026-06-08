Rails.application.routes.draw do
  get "rooms/show"
  get "activities/show"

  devise_for :users

  root to: "activity_sessions#new"

  resources :activity_sessions, only: [:index, :new, :create, :show, :update] do
    collection do
      get :location
      get :duration
    end

    member do
      patch :progress
      patch :pause
      patch :resume
      patch :abandon
    end
  end

  resources :activities, only: [:show]

  resource :user, only: [:show, :edit, :update]

  resource :user_interests, only: [:show, :update]

  resources :room_furnitures, only: [:create, :update, :destroy]

  resources :rooms, only: [:index, :show] do
    resource :like, only: [:create, :destroy], controller: "room_likes"
  end
end
