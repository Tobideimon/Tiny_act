Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  post "activity_sessions/new", to: "activity_sessions#new"
  get "activity_sessions/:id/offer", to: "activity_sessions#offer"
  post "activity_sessions/:id/choose", to: "activity_sessions#choose"
  get "activity_sessions/:id/regenerate", to: "activity_sessions#regenerate"
  get "activity_sessions/:id/activity", to: "activity_sessions#activity"
  post "activity_sessions/:id/done", to: "activity_sessions#done"
  get "activity_sessions/:id/summary", to: "activity_sessions#summary"
  post "activity_sessions/:id/rate", to: "activity_sessions#rate"

  resources :users
  resource :user_interests, only: [:show, :update]
end
