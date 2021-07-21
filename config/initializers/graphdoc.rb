GraphdocRuby.configure do |config|
  config.endpoint = Rails.root.join("tmp/graphql/schema.json")
  config.schema_name = 'MyfifaApiSchema'
end
