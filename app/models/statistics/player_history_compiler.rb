# frozen_string_literal: true

module Statistics
  class PlayerHistoryCompiler
    attr_accessor :team, :player_ids, :season

    def initialize(team:, player_ids: nil, season: nil)
      @team = team
      @player_ids = player_ids
      @season = season
    end

    def results
      season.present? ? season_query : total_query
    end

    private

      def base_query
        PlayerHistory.unscope(:order).where(
          player_id:
            if player_ids.present?
              team.players.where(id: player_ids)
            elsif season.present?
              season_players
            else
              team.players
            end.select(:id)
        )
      end

      def total_query
        query = <<~SQL.squish
          DISTINCT ON (player_id)
          player_id,
          FIRST_VALUE(ovr)
            OVER (
              PARTITION BY player_id
              ORDER BY recorded_on
            ) first_ovr,
          LAST_VALUE(ovr)
            OVER (
              PARTITION BY player_id
              ORDER BY recorded_on
              RANGE BETWEEN
                UNBOUNDED PRECEDING AND
                UNBOUNDED FOLLOWING
            ) last_ovr,
          FIRST_VALUE(value)
            OVER (
              PARTITION BY player_id
              ORDER BY recorded_on
            ) first_value,
          LAST_VALUE(value)
            OVER (
              PARTITION BY player_id
              ORDER BY recorded_on
              RANGE BETWEEN
                UNBOUNDED PRECEDING AND
                UNBOUNDED FOLLOWING
            ) last_value
        SQL

        base_query.pluck(Arel.sql(query)).map do |data|
          {
            player_id: data[0],
            ovr: [data[1], data[2]],
            value: [data[3], data[4]]
          }
        end
      end

      def season_query
        data = base_query
               .where(recorded_on: ..team.end_of_season(season))
               .order(recorded_on: :desc)
               .pluck(:player_id, :recorded_on, :ovr, :value)
        data.group_by(&:first).map do |_player_id, player_records|
          collect_first_and_last_records(player_records)
        end
      end

      def collect_first_and_last_records(records)
        first_value = records.find { |record| record[1] < season_start } ||
                      records.last
        last_value = records.first
        {
          player_id: records.first[0],
          ovr: [first_value[2], last_value[2]],
          value: [first_value[3], last_value[3]]
        }
      end

      def season_players
        team
          .players
          .joins(:contracts)
          .where('contracts.started_on <= ?', team.end_of_season(season))
          .where('contracts.ended_on > ?', season_start)
      end

      def season_start
        @season_start ||= team.started_on + season.years
      end
  end
end
