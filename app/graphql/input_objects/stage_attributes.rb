# frozen_string_literal: true

module InputObjects
  class StageAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Stage record'

    argument :name, String, 'Name of this Stage', required: false
    argument :num_teams, Integer,
             'Number of Teams participating in this Stage', required: false
    argument :num_fixtures, Integer,
             'Number of Fixtures in this Stage', required: false
    argument :table, Boolean, 'Whether this Stage is a Table', required: false

    argument :table_rows_attributes, [TableRowAttributes],
             'List of attributes for rows bound to this Stage', required: false
    argument :fixtures_attributes, [FixtureAttributes],
             'List of attributes for fixtures bound to this Stage',
             required: false
  end
end
