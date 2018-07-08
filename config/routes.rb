Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :exchange_rates, only: [:create], constraints: { format: 'json' } do
   delete :destroy, on: :collection
  end
  resources :exchange_rate_movements, only: [:create], constraints: { format: 'json' } do
    get :search, on: :collection
  end
end
