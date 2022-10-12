# frozen_string_literal: true

module Types
  module Statistics
    class PlayerPerformanceStatsType < BaseTypes::BaseObject
      description 'Player Match Statistics in a Competition and Season'

      stats_field_suffix = 'by Player this Season and Competition'

      field :player_id, ID, 'ID of Player', null: false
      field :season, Integer,
            'Number of complete years after Team Start and this Season',
            null: false
      field :competition, String, 'Name of Competition', null: false
      field :num_matches, Integer,
            "Number of Matches capped #{stats_field_suffix}", null: false
      field :num_minutes, Integer,
            "Number of Minutes played #{stats_field_suffix}", null: false
      field :num_goals, Integer,
            "Number of Goals scored #{stats_field_suffix}", null: false
      field :num_assists, Integer,
            "Number of Goals assisted #{stats_field_suffix}", null: false
      field :num_clean_sheets, Integer,
            "Number of Matches with Clean Sheets capped #{stats_field_suffix}",
            null: false
      field :avg_rating, Float,
            "Average Rating #{stats_field_suffix}", null: false
    end
  end
end
