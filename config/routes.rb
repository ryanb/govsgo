Govsgo::Application.routes.draw do
  resources :games do
    resources :moves
  end
  root :to => 'games#index'
end
