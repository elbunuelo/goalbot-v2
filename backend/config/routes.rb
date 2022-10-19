require 'resque/scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do
  scope '(:locale)', locale: /en|es/ do
    resources :team_aliases, only: [:create]
    resources :subscriptions, only: [:create]
    delete 'subscriptions', to: 'subscriptions#destroy'
    get 'subscriptions/:service/:conversation_id', to: 'subscriptions#list'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
