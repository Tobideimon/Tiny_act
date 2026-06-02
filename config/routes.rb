Rails.application.routes.draw do
  get "activities/show"

  devise_for :users

  root to: "activity_sessions#new"

  resources :activity_sessions, only: [:new, :create, :show] do
    collection do
      get :location
      get :duration
    end
  end

  resources :activities, only: [:show]

  resource :user, only: [:show, :edit, :update]

  resource :user_interests, only: [:show, :update, :create, :destroy]
end
