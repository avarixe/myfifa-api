# frozen_string_literal: true

module Types
  class TeamType < BaseTypes::BaseObject
    description 'Record of a Soccer/Football Club managed by the User'

    field :id, ID, 'Unique Identifer of record', null: false
    field :user_id, ID, 'ID of User', null: false
    field :name, String, 'Name of this Team', null: false
    field :started_on, GraphQL::Types::ISO8601Date,
          'Date the User started to manage this Team', null: false
    field :currently_on, GraphQL::Types::ISO8601Date,
          'Contemporary Date of the Team', null: false
    field :active, Boolean, 'Whether this Team is not archived', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :currency, String,
          'Currency used when managing this Team', null: false

    field :badge_path, String,
          'URI path to the uploaded Badge for this Team', null: true
    field :opponents, [String],
          'List of Teams participating in a Match tracked for this Team',
          null: false
    field :last_match, MatchType, 'Last Match bound to this Team', null: true

    field :players, [PlayerType],
          'List of Players bound to this Team', null: false
    field :matches, [MatchType],
          'List of Matches bound to this Team', null: false
    field :competitions, [CompetitionType],
          'List of Competitions bound to this Team', null: false
    field :squads, [SquadType], 'List of Squads bound to this Team', null: false

    field :match_set, MatchSetType,
          'Subset of Matches bound to this Team', null: false do
      argument :pagination, InputObjects::PaginationAttributes,
               'Pagination options for Match results', required: false
      argument :filters, InputObjects::MatchFilterAttributes,
               'Filters for Match results', required: false
    end

    field :loaned_players, [PlayerType],
          'List of Loaned Players bound to this Team', null: false
    field :injured_players, [PlayerType],
          'List of Injured Players bound to this Team', null: false
    field :expiring_players, [PlayerType],
          'List of Players with Contracts ending at the end of the season',
          null: false

    field :competition_stats, [Statistics::CompetitionStatsType],
          'List of Team performance statistics in each Competition',
          null: false do
      argument :competition, String,
               'Specific Competition to filter results', required: false
      argument :season, Int,
               'Specific Season indicator to filter results', required: false
    end
    field :player_performance_stats, [Statistics::PlayerPerformanceStatsType],
          'List of Player performance statistics in each Competiton',
          null: false do
      argument :player_ids, [ID],
               'List of Player IDs to filter results', required: false
      argument :competition, String,
               'Specific Competition to filter results', required: false
      argument :season, Int,
               'Specific Season indicator to filter results', required: false
    end
    field :player_development_stats, [Statistics::PlayerDevelopmentStatsType],
          'List of Player Overall Rating and Value changes in each Season',
          null: false do
      argument :player_ids, [ID],
               'List of Player IDs to filter results', required: false
      argument :season, Int,
               'Specific Season indicator to filter results', required: false
    end
    field :transfer_activity, Statistics::TransferActivityType,
          'Compilation of Arrivals, Departures, Transfers and Loans ' \
          'in each Season', null: false do
      argument :season, Int,
               'Specific Season indicator to filter results', required: false
    end
    field :team_development_stats, Statistics::TeamDevelopmentStatsType,
          'Average OVR and Total Value changes in a Season',
          null: false do
      argument :season, Int,
               'Specific Season indicator to filter results', required: true
    end

    def match_set(pagination: {}, filters: {})
      set = MatchesCompiler.new(team: object, pagination:, filters:)
      { matches: set.results, total: set.total }
    end

    def competition_stats(competition: nil, season: nil)
      CompetitionCompiler.new(
        team: object,
        competition:,
        season:
      ).results
    end

    def player_performance_stats(
      player_ids: [],
      competition: nil,
      season: nil
    )
      PlayerPerformanceCompiler.new(
        team: object,
        player_ids:,
        competition:,
        season:
      ).results
    end

    def player_development_stats(player_ids: [], season: nil)
      PlayerDevelopmentCompiler.new(
        team: object,
        player_ids:,
        season:
      ).results
    end

    def transfer_activity(season: nil)
      TransferActivityCompiler.new(
        team: object,
        season:
      ).results
    end

    def team_development_stats(season:)
      TeamDevelopmentCompiler.new(
        team: object,
        season:
      ).results
    end
  end
end
