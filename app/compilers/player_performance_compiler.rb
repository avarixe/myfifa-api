# frozen_string_literal: true

class PlayerPerformanceCompiler
  attr_accessor :team, :player_ids, :competition, :season

  def initialize(team:, player_ids: nil, competition: nil, season: nil)
    @team = team
    @player_ids = player_ids
    @competition = competition
    @season = season
  end

  def results
    num_matches.map do |key, matches|
      {
        player_id: key[0],
        season: key[1],
        competition: key[2],
        num_matches: matches,
        num_minutes: num_minutes[key],
        num_goals: num_goals[key] || 0,
        num_assists: num_assists[key] || 0,
        num_clean_sheets: num_clean_sheets[key] || 0
      }
    end
  end

  private

    def base_player_query
      @base_player_query ||= team.players.where({
        id: player_ids.presence,
        matches: {
          competition: competition,
          season: season
        }.compact.presence
      }.compact).group(:id, 'matches.season', 'matches.competition')
    end

    def num_goals
      @num_goals ||= base_player_query.joins(goals: :match).count
    end

    def num_assists
      @num_assists ||= base_player_query.joins(assists: :match).count
    end

    def num_clean_sheets
      @num_clean_sheets ||= begin
        query = base_player_query.joins(:matches)
        query
          .where(matches: { away_score: 0, home: team.name })
          .or(query.where(matches: { home_score: 0, away: team.name }))
          .count
      end
    end

    def num_matches
      @num_matches ||= base_player_query.joins(:matches).count
    end

    def num_minutes
      @num_minutes ||= base_player_query.joins(caps: :match).sum('stop - start')
    end
end
