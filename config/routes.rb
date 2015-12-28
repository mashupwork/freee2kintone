Rails.application.routes.draw do
  get 'auth/freee' => 'sessions#freee'
  #get 'auth/:provider/callback', to: 'sessions#callback'
  get '/auth/timecrowd/callback', to: 'sessions#timecrowd_callback'
  get 'auth/failure', to: 'sessions#failure'
  root 'welcome#index'
end
