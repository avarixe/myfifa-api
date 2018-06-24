Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  devise_for :users,
             only: :registrations,
             controllers: {
               registrations: 'users/registrations'
             }

  constraints format: :json do
    get 'users/sync', to: 'users#sync'

    resources :teams, shallow: true do
      resources :players do
        resources :loans
        resources :injuries
        resources :contracts
        resources :transfers
      end
    end
  end
end
