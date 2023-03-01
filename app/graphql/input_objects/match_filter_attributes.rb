# frozen_string_literal: true

module InputObjects
  class MatchFilterAttributes < BaseTypes::BaseInputObject
    description 'Attributes to filter a Match set'

    argument :season, Integer,
             'Number of complete years after Team Start', required: false
    argument :competition, String, 'Name of Competition', required: false
    argument :stage, String, 'Name of Competition Stage', required: false
    argument :team, String, 'Name of Home or Away Team', required: false
    argument :result, [Enums::MatchResultEnum],
             'Result relative to tracked Team', required: false
    argument :played_on, GraphQL::Types::ISO8601Date,
             'Date this Match was played', required: false
  end
end
