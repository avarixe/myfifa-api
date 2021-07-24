# frozen_string_literal: true

class QueryType < BaseTypes::BaseObject
  # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
  include GraphQL::Types::Relay::HasNodeField
  include GraphQL::Types::Relay::HasNodesField

  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :user, Types::UserType, 'Data about the current User', null: true
  field :teams, [Types::TeamType],
        'List of all Teams owned by User', null: true
  field :team, Types::TeamType, 'Specific Team owned by User', null: true do
    argument :id, ID, 'ID of Team', required: true
  end
  field :player, Types::PlayerType,
        'Specific Player bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Player', required: true
  end
  field :match, Types::MatchType,
        'Specific Match bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Match', required: true
  end
  field :competition, Types::CompetitionType,
        'Specific Competition bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Competition', required: true
  end

  def user
    context[:current_user]
  end

  delegate :teams, to: :user, allow_nil: true

  def team(id:)
    teams&.find(id)
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
