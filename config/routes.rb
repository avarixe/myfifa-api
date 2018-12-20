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
          post 'release'
          post 'retire'
          get 'history'
          get 'current_loan'
          get 'current_injury'
        end

        resources :loans
        resources :injuries
        resources :contracts
        resources :transfers
      end

      get 'loans', to: 'loans#team_index'
      get 'injuries', to: 'injuries#team_index'
      get 'contracts', to: 'contracts#team_index'
      get 'transfers', to: 'transfers#team_index'

      resources :squads
      resources :matches do
        member do
          get 'events'
          post 'apply_squad'
        end

        resources :caps
        resources :goals
        resources :substitutions
        resources :bookings
        resource :penalty_shootout, controller: :penalty_shootout
      end

      resources :competitions do
        resources :stages do
          resources :table_rows
          resources :fixtures
        end
      end

      namespace :analyze do
        post 'players', to: 'players#index'
        post 'season/:id',  to: 'season#index', as: :season
      end
    end
  end
end
