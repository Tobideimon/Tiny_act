Rails.application.routes.draw do
  get "rooms/show"
  get "activities/show"

  devise_for :users

  root to: "activity_sessions#new"

  resources :activity_sessions, only: [:new, :create, :show, :update] do
    collection do
      get :location
      get :duration
    end

    member do
      patch :progress
    end
  end

  resources :activities, only: [:show]

  resource :user, only: [:show, :edit, :update]

  resource :user_interests, only: [ :show, :update ]

  resource :room, only: [:show]
  resources :room_furnitures, only: [:create, :update, :destroy]
end
