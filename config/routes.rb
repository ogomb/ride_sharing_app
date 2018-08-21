Rails.application.routes.draw do

  namespace :admin do
    root 'application#index'

    resources :rides, only: [:new, :create, :destroy]
    resources :users do
      member do
        patch :archive
      end
    end
  end
  devise_for :users

  root "rides#index"

  resources :rides, only: [:index, :show, :edit, :update] do
    resources :interests
  end
end
