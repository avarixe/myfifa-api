# frozen_string_literal: true

module Types
  class QueryType < BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :teams, [Myfifa::TeamType], null: false
    field :team, Myfifa::TeamType, null: false do
      argument :id, ID, required: true
    end

    def teams
      current_ability = Ability.new(context[:current_user])
      Team.accessible_by(current_ability).all
    end

    def team(id:)
      current_ability = Ability.new(context[:current_user])
      Team.accessible_by(current_ability).find(id)
    end
  end
end
