Rails.application.routes.draw do
  get 'login' => 'sessions#login'
  get 'callback' => 'sessions#callback'
end
