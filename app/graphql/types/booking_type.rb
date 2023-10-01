# frozen_string_literal: true

module Types
  class BookingType < BaseTypes::BaseObject
    description 'Record of a Yellow or Red Card penalization'

    field :id, ID, 'Unique Identifier of record', null: false
    field :match_id, ID, 'ID of Match', null: false
    field :minute, Integer, 'Minute of Match this occurred', null: false
    field :cap_id, ID, 'ID of Player Cap booked if record exists', null: true
    field :player_id, ID, 'ID of Player booked if record exists', null: true
    field :red_card, Boolean,
          'Whether Booking was a Yellow (false) or Red (true) Card', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :player_name, String, 'Name of Player booked', null: false
    field :home, Boolean,
          'Whether Booking was for a Player on the Home Team', null: false

    field :match, MatchType, 'Match where Booking occurred', null: false
    field :player, PlayerType, 'Booked Player', null: false
  end
end
