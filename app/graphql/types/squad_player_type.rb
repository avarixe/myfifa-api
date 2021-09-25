# frozen_string_literal: true

module Types
  class SquadPlayerType < BaseTypes::BaseObject
    description 'Record of a Player slot in a Squad'

    field :id, ID, 'Unique Identifer of record', null: false
    field :squad_id, ID, 'ID of Squad', null: false
    field :player_id, ID, 'ID of Player assigned to this slot', null: false
    field :pos, Enums::CapPositionEnum,
          'Position designated for this slot', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :squad, SquadType, 'Squad pertaining to this record', null: false
    field :player, PlayerType, 'Player assigned to this slot', null: false
  end
end
