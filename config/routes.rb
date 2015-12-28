Rails.application.routes.draw do
  get 'auth/freee' => 'sessions#freee' # 非omniauth
  get 'auth/:provider/callback', to: 'sessions#callback'
  get 'auth/failure', to: 'sessions#failure'
  root 'welcome#index'
end
