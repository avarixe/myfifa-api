# frozen_string_literal: true

module Types
  class StageType < BaseTypes::BaseObject
    description 'Record of a Table or Elimination Round in a Competition'

    field :id, ID, 'Unique Identifer of record', null: false
    field :competition_id, ID, 'ID of Competition', null: false
    field :name, String, 'Name of this Stage', null: false
    field :num_teams, Integer,
          'Number of Teams participating in this Stage', null: true
    field :num_fixtures, Integer, 'Number of Fixtures in this Stage', null: true
    field :table, Boolean, 'Whether this Stage is a Table', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :competition, CompetitionType,
          'Competition pertaining to this Stage', null: false
    field :table_rows, [TableRowType],
          'Table Rows bound to this Stage (if a Table)', null: false
    field :fixtures, [FixtureType],
          'Fixtures bound to this Stage (if an Elimination Round)', null: false
  end
end
