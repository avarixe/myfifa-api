# frozen_string_literal: true

module Types
  module Statistics
    class PlayerDevelopmentStatsType < BaseTypes::BaseObject
      description 'Player Overall Rating and Value Changes in a Season'

      field :player_id, ID, 'ID of Player', null: false
      field :season, Int,
            'Number of complete years after Team Start and this Season',
            null: false
      field :ovr, [Int],
            'Overall Rating of Player at start and end of this Season',
            null: false
      field :value, [Int],
            'Value of Player at start and end of this Season', null: false
    end
  end
end
