# frozen_string_literal: true

module Types
  module Myfifa
    class TeamType < BaseObject
      field :id, ID, null: false
      field :user_id, ID, null: false
      field :name, String, null: false
      field :started_on, GraphQL::Types::ISO8601Date, null: false
      field :currently_on, GraphQL::Types::ISO8601Date, null: false
      field :active, Boolean, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :currency, String, null: false

      field :time_period, String, null: false
      field :badge_path, String, null: true
      field :opponents, [String], null: false

      field :players, [PlayerType], null: false
      field :matches, [MatchType], null: false
      field :competitions, [CompetitionType], null: false
      field :squads, [SquadType], null: false

      field :competition_stats,
            [Statistics::CompetitionStatsType],
            null: false do
        argument :competition, String, required: false
        argument :season, Int, required: false
      end
      field :player_performance_stats,
            [Statistics::PlayerPerformanceStatsType],
            null: false do
        argument :player_ids, [ID], required: false
        argument :competition, String, required: false
        argument :season, Int, required: false
      end
      field :player_development_stats,
            [Statistics::PlayerDevelopmentStatsType],
            null: false do
        argument :player_ids, [ID], required: false
        argument :season, Int, required: false
      end
      field :transfer_activity,
            Statistics::TransferActivityType,
            null: false do
        argument :season, Int, required: false
      end
    end
  end
end
