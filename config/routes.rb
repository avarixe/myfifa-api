Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  post '/graphql', to: 'graphql#execute'
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  mount GraphdocRuby::Application, at: '/graphdoc'

  constraints format: :json do
    resources :teams, only: [] do
      post 'badge', on: :member, to: 'teams#add_badge'
      delete 'badge', on: :member, to: 'teams#remove_badge'
    end
  end
end
