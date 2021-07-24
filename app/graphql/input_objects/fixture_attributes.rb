# frozen_string_literal: true

module InputObjects
  class FixtureAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Fixture record'

    argument :home_team, String, 'Name of Home Team', required: true
    argument :away_team, String, 'Name of Away Team', required: true

    argument :legs_attributes,
             [FixtureLegAttributes],
             'List of attributes for legs bound to this Fixture',
             required: true
  end
end
