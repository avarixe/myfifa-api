Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  post '/graphql', to: 'graphql#execute'
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  mount GraphdocRuby::Application, at: '/graphdoc'
end
