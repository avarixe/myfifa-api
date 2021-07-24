# frozen_string_literal: true

module Types
  class SubstitutionType < BaseTypes::BaseObject
    description 'Record of a Player being replaced in a Match'

    field :id, ID, 'Unique Identifer of record', null: false
    field :match_id, ID, 'ID of Match', null: false
    field :minute, Integer, 'Minute of Match this occurred', null: false
    field :player_id, ID, 'ID of the Player who was replaced', null: false
    field :replacement_id, ID, 'ID of the replacement Player', null: false
    field :injury, Boolean,
          'Whether the Player was replaced due to injury', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :player_name, String,
          'Name of the Player who was replaced', null: false
    field :replaced_by, String, 'Name of the replacing Player', null: false

    field :player, PlayerType, 'Player who was replaced', null: false
    field :replacement, PlayerType, 'Replacing Player', null: false
  end
end
