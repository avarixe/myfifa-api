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

        collection do
          patch :update_multiple
        end
      end
      resources :squads
      resources :matches do
        post 'apply_squad', on: :member

        resources :logs, controller: :match_logs
        resources :goals
        resources :substitutions
        resources :bookings
        resources :penalty_shootouts
      end
    end
  end
end
