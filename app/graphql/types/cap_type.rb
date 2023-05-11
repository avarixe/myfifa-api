# frozen_string_literal: true

module Types
  class CapType < BaseTypes::BaseObject
    description 'Record of a Player participating in a Match'

    field :id, ID, 'Unique Identifier of record', null: false
    field :match_id, ID, 'ID of Match', null: false
    field :player_id, ID, 'ID of Player', null: false
    field :pos, Enums::CapPositionEnum,
          'Position assigned to Player during Match', null: false
    field :start, Integer, 'Minute of Match Player started', null: false
    field :stop, Integer, 'Minute of Match Player stopped', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :subbed_out, Boolean,
          'Whether the Player was substituted out of the Match', null: false
    field :rating, Integer,
          'Performance Rating of the Player in this Match', null: true
    field :ovr, Integer,
          'Overall Rating of the Player in this Match', null: false

    field :match, MatchType, 'Match pertaining to this Cap', null: false
    field :player, PlayerType, 'Player pertaining to this Cap', null: false
  end
end
