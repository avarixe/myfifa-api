Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users,
             only: :registrations,
             controllers: {
               registrations: 'users/registrations'
             }

  namespace :api, defaults: { format: :json }, path: '/' do
    get 'users/sync', to: 'users#sync'
  end
end
