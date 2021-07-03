# frozen_string_literal: true

module Types
  class QueryType < BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    %w[
      Team
      Player
      Match
      Squad
      Competition
    ].each do |model|
      model_type = Myfifa.const_get("#{model}Type")
      model_class = model.constantize

      field model.underscore.pluralize, [model_type], null: false
      field model.underscore, model_type, null: false do
        argument :id, ID, required: true
      end

      define_method model.underscore.pluralize do
        current_ability = Ability.new(context[:current_user])
        model_class.accessible_by(current_ability).all
      end

      define_method model.underscore do |id:|
        current_ability = Ability.new(context[:current_user])
        model_class.accessible_by(current_ability).find(id)
      end
    end

    field :user, Myfifa::UserType, null: false
    def user
      context[:current_user]
    end
  end
end
