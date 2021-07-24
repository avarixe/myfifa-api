# frozen_string_literal: true

module Types
  class SquadType < BaseTypes::BaseObject
    description 'Record of a selection of eleven Players and Positions ' \
                'for easy Cap insertion in a Match'

    field :id, ID, 'Unique Identifer of record', null: false
    field :team_id, ID, 'ID of Team', null: false
    field :name, String, 'Name of this Squad', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :team, TeamType, 'Team pertaining to this Squad', null: false
    field :squad_players, [SquadPlayerType],
          'List of Player/Position slots for this Squad', null: false
  end
end
