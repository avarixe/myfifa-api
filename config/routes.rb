Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

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
        member do
          get 'history'
          get 'current_loan'
          get 'current_injury'
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

        resources :performances
        resources :goals
        resources :substitutions
        resources :bookings
        resources :penalty_shootouts
      end

      resources :competitions do
        resources :stages do
          resources :table_rows
          resources :fixtures
        end
      end

      post 'statistics', to: 'statistics#index'
    end
  end
end
