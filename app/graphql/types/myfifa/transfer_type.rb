# frozen_string_literal: true

module Types
  module Myfifa
    class TransferType < BaseObject
      description 'Record of a Player moving to a different Team'

      field :id, ID, 'Unique Identifer of record', null: false
      field :player_id, ID, 'ID of Player', null: false
      field :signed_on, GraphQL::Types::ISO8601Date,
            'Date of Team when Transfer is created', null: false
      field :moved_on, GraphQL::Types::ISO8601Date,
            'Date when Player moved to a different Team', null: false
      field :origin, String,
            'Name of Team this Player is transferred from', null: false
      field :destination, String,
            'Name of Team this Player is transferred to', null: false
      field :fee, Integer,
            'Transfer Fee paid to the original Team', null: true
      field :traded_player, String,
            'Name of Player swapped for this Transfer', null: true
      field :addon_clause, Integer,
            'Percentage of Transfer Fee to be received from the ' \
            'destination Team if they sell this Player',
            null: true
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false

      field :player, PlayerType, 'Player that was transferred', null: false
    end
  end
end
