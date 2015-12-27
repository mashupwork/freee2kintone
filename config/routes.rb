Rails.application.routes.draw do
  get 'auth/:provider' => 'sessions#login'
  get 'auth/:provider/callback' => 'sessions#callback'
  root 'welcome#index'
end
