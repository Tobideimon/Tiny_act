# Rails.application.routes.draw do
# devise_for :users
# root to: "activity_sessions#new"
#  post "activity_sessions/new", to: "activity_sessions#new"
#  get "activity_sessions/:id/offer", to: "activity_sessions#offer"
#  post "activity_sessions/:id/choose", to: "activity_sessions#choose"
#  get "activity_sessions/:id/regenerate", to: "activity_sessions#regenerate"
#  get "activity_sessions/:id/activity", to: "activity_sessions#activity"
#  post "activity_sessions/:id/done", to: "activity_sessions#done"
#  get "activity_sessions/:id/summary", to: "activity_sessions#summary"
#  post "activity_sessions/:id/rate", to: "activity_sessions#rate"

 # patch "user_interests", to: "user_interests#patch"
#end

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

  resources :user_interests, only: [:create, :destroy]
end
