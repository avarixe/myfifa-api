# frozen_string_literal: true

module InputObjects
  class MatchAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Match record'

    argument :home, String, 'Name of Home Team', required: false
    argument :away, String, 'Name of Away Team', required: false
    argument :competition, String, 'Name of Competition', required: false
    argument :played_on, GraphQL::Types::ISO8601Date,
             'Date this Match was played', required: false
    argument :extra_time, Boolean,
             'Whether this Match required an Extra 30 Minutes',
             required: false
    argument :stage, String, 'Name of Competition Stage', required: false
    argument :home_xg, Float, 'Expected Goals for Home Team', required: false
    argument :away_xg, Float, 'Expected Goals for Away Team', required: false
    argument :home_possession, Integer,
             'Percentage of Possession for Home Team', required: false
    argument :away_possession, Integer,
             'Percentage of Possession for Away Team', required: false

    argument :penalty_shootout_attributes, PenaltyShootoutAttributes,
             'Attributes for Penalty Shootout bound to this Match',
             required: false
  end
end
