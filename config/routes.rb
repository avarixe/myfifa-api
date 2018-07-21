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
        %i[ goals substitutions bookings penalty_shootouts ].each do |event|
          resources event.to_sym,
                    controller: :events,
                    type: event
        end
      end
    end
  end
end
