# frozen_string_literal: true

module Types
  class PenaltyShootoutType < BaseTypes::BaseObject
    description 'Record of a Penalty Shootout in a Match'

    field :id, ID, 'Unique Identifer of record', null: false
    field :match_id, ID, 'ID of Match', null: false
    field :home_score, Integer, 'Penalties scored by Home Team', null: false
    field :away_score, Integer, 'Penalties scored by Away Team', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :match, MatchType,
          'Match pertaining to this Penalty Shootout', null: false
  end
end
