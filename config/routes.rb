Govsgo::Application.routes.draw do
  resources :messages

  match 'auth/:provider/callback' => 'authentications#create'
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signin' => 'authentications#index', :as => :signin
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  match 'go_resources' => 'games#resources', :as => :go_resources
  match 'games/:id.sgf' => 'games#sgf', :format => "sgf", :as => "game_sgf"
  match 'unsubscribe/:token' => 'users#unsubscribe', :as => "unsubscribe"
  match 'publicize' => 'users#publicize', :as => "publicize"
  resources :authentications
  resources :sessions
  resources :users
  resources :games do
    resources :moves
    collection do
      get :your
      get :other
    end
  end
  root :to => 'games#index'
end
