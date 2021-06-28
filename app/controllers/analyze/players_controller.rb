# frozen_string_literal: true

module Analyze
  class PlayersController < ApiController
    include Analyzer
    load_and_authorize_resource :team
    before_action :set_player_ids
    before_action :set_match_ids

    def index
      render json: {
        player_ids: @player_ids,
        num_games: num_games,
        num_goals: num_goals,
        num_assists: num_assists,
        num_cs: num_cs,
        num_minutes: num_minutes
      }
    end

    private

      def set_player_ids
        @player_ids = stat_params[:player_ids] ||
                      @team.players.pluck(:id).map(&:to_s)
      end

      def set_match_ids
        @match_ids = stat_params[:match_ids] ||
                     @team.matches.distinct.pluck(:id).map(&:to_s)
      end

      def stat_params
        params
          .fetch(:query, {})
          .permit(player_ids: [], match_ids: [])
      end
  end
end
