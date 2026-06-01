Rails.application.routes.draw do
  devise_for :users

  root to: "activity_sessions#new"

  get "activity_sessions/location", to: "activity_sessions#location", as: :activity_session_location
  get "activity_sessions/duration", to: "activity_sessions#duration", as: :activity_session_duration
  get "activity_sessions/offer", to: "activity_sessions#offer", as: :offer_activity_sessions

  post "activity_sessions/:activity_id/choose", to: "activity_sessions#choose", as: :choose_activity_session

  resources :activity_sessions, only: [:show, :update] do
    member do
      post :done
      post :rate
      get :summary
    end
  end
  resources :users
  resource :user_interests, only: [:show, :update, :create, :destroy]
end
