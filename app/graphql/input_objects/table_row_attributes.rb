# frozen_string_literal: true

module InputObjects
  class TableRowAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Table Row record'

    argument :id, ID, 'Unique Identifer of record', required: false
    argument :_destroy, Boolean,
             'Whether to destroy this record', required: false
    argument :name, String, 'Name of Team for this row', required: false
    argument :wins, Integer,
             'Number of Matches Won by this Team', required: false
    argument :draws, Integer,
             'Number of Matches Drawn by this Team', required: false
    argument :losses, Integer,
             'Number of Matches Lost by this Team', required: false
    argument :goals_for, Integer,
             'Number of Goals scored for this Team', required: false
    argument :goals_against, Integer,
             'Number of Goals scored against this Team', required: false
  end
end
