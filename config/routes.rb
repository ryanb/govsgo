Govsgo::Application.routes.draw do
  match '/auth/:provider/callback' => 'authentications#create'
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signin' => 'authentications#index', :as => :signin
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  match 'go_resources' => 'games#resources', :as => :go_resources
  resources :authentications
  resources :sessions
  resources :users
  resources :games do
    resources :moves
    collection do
      get :my
      get :other
    end
  end
  root :to => 'games#index'
end
