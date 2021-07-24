# frozen_string_literal: true

module Types
  class FixtureType < BaseTypes::BaseObject
    description 'Record of a Match in a Competition Stage'

    field :id, ID, 'Unique Identifer of record', null: false
    field :stage_id, ID, 'ID of Stage', null: false
    field :home_team, String, 'Name of Home Team', null: true
    field :away_team, String, 'Name of Away Team', null: true
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :stage, StageType, 'Stage pertaining to this Fixture', null: false
    field :legs, [FixtureLegType],
          'List of Fixture Legs bound to this Fixture', null: false
  end
end
