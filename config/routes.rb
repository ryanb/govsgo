Govsgo::Application.routes.draw do
  match '/auth/:provider/callback' => 'authentications#create'
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  resources :authentications
  resources :sessions
  resources :users
  resources :games do
    resources :moves
  end
  root :to => 'games#index'
end
