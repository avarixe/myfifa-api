# frozen_string_literal: true

RSpec::GraphQLResponse.configure do |config|
  config.graphql_schema = MyfifaApiSchema
end
