Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users,
             only: :registrations,
             controllers: {
               registrations: 'users/registrations'
             }

  constraints format: :json do
    get 'users/sync', to: 'users#sync'

    resources :teams do
      resources :players do
        resources :loans
        resources :injuries
        resources :contracts
      end
    end
  end
end
