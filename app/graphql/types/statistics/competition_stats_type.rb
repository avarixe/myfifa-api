# frozen_string_literal: true

module Types
  module Statistics
    class CompetitionStatsType < BaseObject
      description 'Statistics for a Competition in a Season'

      field :season, Integer,
            'Number of complete years between Team Start and this Season',
            null: false
      field :competition, String, 'Name of Competition', null: false
      field :wins, Integer, 'Number of Wins in Competition', null: false
      field :draws, Integer, 'Number of Draws in Competition', null: false
      field :losses, Integer, 'Number of Losses in Competition', null: false
      field :goals_for, Integer,
            'Number of Goals For in Competition', null: false
      field :goals_against, Integer,
            'Number of Goals Against in Competition', null: false
    end
  end
end
