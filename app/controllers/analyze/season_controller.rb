# frozen_string_literal: true

module Analyze
  class SeasonController < APIController
    include Analyzer
    load_and_authorize_resource :team
    before_action :set_season_data
    before_action :set_player_ids
    before_action :set_match_ids

    def index
      render json: {
        player_ids:  @player_ids,
        num_games:   num_games,
        num_goals:   num_goals,
        num_assists: num_assists,
        num_cs:      num_cs,
        num_minutes: num_minutes
      }
    end

    private

      def set_season_data
        @season = @team.season_data(params[:id].to_i)
      end

      def set_player_ids
        @player_ids = @team.players.pluck(:id)
        @player_ids &= Contract.where(
          'effective_date <= ? AND ? < end_date',
          @season[:end],
          @season[:start]
        ).pluck(:player_id)
        @player_ids.map!(&:to_s)
      end

      def set_match_ids
        @match_ids = Match
                     .where(date_played: @season[:start]..@season[:end])
                     .pluck(:id)
                     .map(&:to_s)
      end
  end
end
