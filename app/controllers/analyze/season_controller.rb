# frozen_string_literal: true

module Analyze
  class SeasonController < APIController
    include Analyzer
    load_and_authorize_resource :team
    before_action :set_season_data
    before_action :set_player_ids
    before_action :set_match_ids

    def index
      stats = [
        player_stats,
        match_stats
      ]
      render json: stats.reduce(&:merge)
    end

    private

      def set_season_data
        @season = @team.season_data(params[:id].to_i)
      end

      def set_player_ids
        @player_ids = @team.players.pluck(:id)
        @player_ids &= Contract.where(
          'started_on <= ? AND ? < ended_on',
          @season[:end],
          @season[:start]
        ).pluck(:player_id)
        @player_ids.map!(&:to_s)
      end

      def set_match_ids
        @match_ids = @team
                     .matches
                     .where(played_on: @season[:start]..@season[:end])
                     .pluck(:id)
                     .map(&:to_s)
      end

      def player_stats
        {
          player_ids: @player_ids,
          records: season_players,
          num_games: num_games,
          num_subs: num_subs,
          num_goals: num_goals,
          num_assists: num_assists,
          num_cs: num_cs,
          num_minutes: num_minutes
        }
      end

      def match_stats
        {
          results: match_results
        }
      end
  end
end
