# frozen_string_literal: true

module Types
  module Myfifa
    class TableRowType < BaseObject
      description 'Record of a row in a Table Stage'

      field :id, ID, 'Unique Identifer of record', null: false
      field :stage_id, ID, 'ID of Stage', null: false
      field :name, String, 'Name of Team for this row', null: true
      field :wins, Integer, 'Number of Matches Won by this Team', null: true
      field :draws, Integer, 'Number of Matches Drawn by this Team', null: true
      field :losses, Integer, 'Number of Matches Lost by this Team', null: true
      field :goals_for, Integer,
            'Number of Goals scored for this Team', null: true
      field :goals_against, Integer,
            'Number of Goals scored against this Team', null: true
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false

      field :goal_difference, Integer,
            'Number of goals scored for this Team subtracted from ' \
            'number of goals scored against this Team',
            null: false
      field :points, Integer,
            "Points scored by this Team in the Group/League\n" \
            '(3 per Win, 1 per Draw, 0 per Loss)',
            null: false

      field :stage, StageType, 'Stage pertaining to this row', null: false
    end
  end
end
