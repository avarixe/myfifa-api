# frozen_string_literal: true

module Types
  class CompetitionType < BaseTypes::BaseObject
    description 'Record of a League/Cup in a Season'

    field :id, ID, 'Unique Identifer of record', null: false
    field :team_id, ID, 'ID of Team', null: false
    field :season, Integer,
          'Number of complete years between Team Start and this Competition',
          null: false
    field :name, String, 'Name of this Competition', null: false
    field :champion, String,
          'Name of Team that won this Competition', null: true
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :team, TeamType, 'Team bound to this Competition', null: false
    field :stages, [StageType],
          'List of Stages in this Competition', null: false
  end
end
