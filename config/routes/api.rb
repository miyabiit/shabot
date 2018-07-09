namespace :api do
  resources :receipts, only: [:index, :show]
  resources :payments, only: [:index, :show]
  resources :my_accounts, only: [:index, :show]
  resources :accounts, only: [:index, :show]
  resources :my_corporations, only: [:index, :show]
  resources :items, only: [:index, :show]
  resources :projects, only: [:index, :show]
end
