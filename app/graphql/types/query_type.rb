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
      argument :id, ID, 'ID of Team', required: true
    end
    field :player, Myfifa::PlayerType, null: false do
      argument :id, ID, 'ID of Player', required: true
    end
    field :match, Myfifa::MatchType, null: false do
      argument :id, ID, 'ID of Match', required: true
    end
    field :competition, Myfifa::CompetitionType, null: false do
      argument :id, ID, 'ID of Competition', required: true
    end

    def teams
      Team.accessible_by(current_ability).all
    end

    def team(id:)
      Team.accessible_by(current_ability).find(id)
    end

    def player(id:)
      Player.accessible_by(current_ability).find(id)
    end

    def match(id:)
      Match.accessible_by(current_ability).find(id)
    end

    def competition(id:)
      Competition.accessible_by(current_ability).find(id)
    end

    private

      def current_ability
        Ability.new(context[:current_user])
      end
  end
end
