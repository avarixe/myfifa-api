# frozen_string_literal: true

class TeamDevelopmentCompiler
  attr_accessor :team, :season

  def initialize(team:, season:)
    @team = team
    @season = season
  end

  def results
    {
      season:,
      start_ovr:,
      start_value:,
      end_ovr:,
      end_value:
    }
  end

  %w[start end].each do |time|
    define_method "#{time}_ovr" do
      player_ovrs = PlayerHistory
                    .unscope(:order)
                    .where(player_id: public_send("player_ids_at_#{time}"))
                    .where(recorded_on: nil..public_send("season_#{time}"))
                    .pluck(Arel.sql(query_last_value_per_player_id('ovr')))
                    .pluck(1)
      player_ovrs.sum(0) / player_ovrs.size
    end

    define_method "#{time}_value" do
      player_values = PlayerHistory
                      .unscope(:order)
                      .where(player_id: public_send("player_ids_at_#{time}"))
                      .where(recorded_on: nil..public_send("season_#{time}"))
                      .pluck(Arel.sql(query_last_value_per_player_id('value')))
                      .pluck(1)
      player_values.sum(0)
    end

    define_method "player_ids_at_#{time}" do
      Contract
        .active_for(team:, date: public_send("season_#{time}"))
        .select(:player_id)
    end
  end

  def query_last_value_per_player_id(attribute)
    <<~SQL.squish
      DISTINCT ON (player_id)
      player_id,
      LAST_VALUE(#{attribute})
        OVER (
          PARTITION BY player_id
          ORDER BY recorded_on
          RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING
        ) last_#{attribute}
    SQL
  end

  def season_start
    @season_start ||= team.started_on + season.years
  end

  def season_end
    @season_end ||=
      if team.current_season == season
        team.currently_on
      else
        team.end_of_season(season)
      end
  end
end
