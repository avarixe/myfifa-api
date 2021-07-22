# frozen_string_literal: true

module Types
  module Myfifa
    class PlayerHistoryType < BaseObject
      description 'Record of Player Overall Rating, Value, and Kit Number ' \
                  'on a specific date'

      field :id, ID, 'Unique Identifer of record', null: false
      field :player_id, ID, 'ID of Player', null: false
      field :recorded_on, GraphQL::Types::ISO8601Date,
            'Date on which the Player had these values', null: false
      field :ovr, Integer, 'Overall Rating of Player', null: false
      field :value, Integer, 'Value of Player', null: false
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false
      field :kit_no, Integer, 'Kit Number assigned to Player', null: true

      field :player, PlayerType, 'Player pertaining to this record', null: false
    end
  end
end
