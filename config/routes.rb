Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  #auth routes
  devise_for :users
  
  resources :dashboard, only: [:index]
  resources :facilities
  
  root 'landing#index'  
end