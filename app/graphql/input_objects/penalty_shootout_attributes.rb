# frozen_string_literal: true

module InputObjects
  class PenaltyShootoutAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Penalty Shootout record'

    argument :home_score, Integer,
             'Penalties scored by Home Team', required: true
    argument :away_score, Integer,
             'Penalties scored by Away Team', required: true
  end
end
