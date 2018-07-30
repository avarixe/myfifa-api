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
        collection do
          patch :update_multiple
        end
        member do
          get 'active_loan'
          get 'active_injury'
        end

        resources :loans
        resources :injuries
        resources :contracts
        resources :transfers
      end
      resources :squads
      resources :matches do
        member do
          get 'events'
          post 'apply_squad'
        end

        resources :logs, controller: :match_logs
        resources :goals
        resources :substitutions
        resources :bookings
        resources :penalty_shootouts
      end
    end
  end
end
