# frozen_string_literal: true

class PlayerDevelopmentCompiler
  attr_accessor :team, :player_ids, :season

  def initialize(team:, player_ids: nil, season: nil)
    @team = team
    @player_ids = player_ids
    @season = season
  end

  def results
    @results ||= season.present? ? season_query : total_query
  end

  private

    def player_history_query
      PlayerHistory.where(
        player_id:
          if player_ids.present?
            team.players.where(id: player_ids)
          else
            season_players
          end.select(:id)
      )
    end

    def total_query
      [].tap do |total_data|
        (0..team.current_season).map do |season|
          @season = season
          total_data.concat season_query
        end
      end
    end

    def season_query
      data = player_history_query
             .where(recorded_on: nil..season_end)
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
        season:,
        player_id: records.first[0],
        ovr: [first_value[2], last_value[2]],
        value: [first_value[3], last_value[3]]
      }
    end

    def season_players
      team
        .players
        .joins(:contracts)
        .where('contracts.started_on <= ?', season_end)
        .where('contracts.ended_on > ?', season_start)
    end

    def season_start
      team.started_on + season.years
    end

    def season_end
      team.end_of_season(season)
    end
end
