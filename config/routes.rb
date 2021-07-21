Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  post '/graphql', to: 'graphql#execute'
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  mount GraphdocRuby::Application, at: '/'

  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints format: :json do
    resource :user, controller: :user, only: %i[show create update] do
      patch 'password', action: 'change_password', on: :member
    end

    resources :teams, only: [] do
      post 'badge', on: :member, to: 'teams#add_badge'
      delete 'badge', on: :member, to: 'teams#remove_badge'
    end
  end
end
