# frozen_string_literal: true

module InputObjects
  class FixtureLegAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Fixture Leg record'

    argument :id, ID, 'Unique Identifer of record', required: false
    argument :_destroy, Boolean,
             'Whether to destroy this record', required: false
    argument :home_score, String, 'Score of the Home Team', required: true
    argument :away_score, String, 'Score of the Away Team', required: true
  end
end
