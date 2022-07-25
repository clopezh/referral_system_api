Rails.application.routes.draw do
  resources :users
  resources :referrals
  resources :roles, only: [:create, :index]
end
