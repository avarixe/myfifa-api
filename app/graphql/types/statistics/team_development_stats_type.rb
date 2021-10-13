# frozen_string_literal: true

module Types
  module Statistics
    class TeamDevelopmentStatsType < BaseTypes::BaseObject
      description 'Average OVR and Total Value Changes in a Season'

      field :season, Int,
            'Number of complete years after Team Start and this Season',
            null: false
      field :start_ovr, Int,
            'Average OVR of Players at start of this Season', null: false
      field :start_value, GraphQL::Types::BigInt,
            'Total Value of Players at start of this Season', null: false
      field :end_ovr, Int,
            'Average OVR of Players currently or at end of this Season',
            null: false
      field :end_value, GraphQL::Types::BigInt,
            'Total Value of Players currently or at end of this Season',
            null: false
    end
  end
end
