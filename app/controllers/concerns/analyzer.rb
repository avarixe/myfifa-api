# frozen_string_literal: true

module Analyzer
  extend ActiveSupport::Concern

  private

    def num_games
      Performance
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(id)'))
        .to_h
    end

    def num_subs
      Substitution
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:replacement_id)
        .pluck(Arel.sql('replacement_id, COUNT(id)'))
        .to_h
    end

    def num_goals
      Goal
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(id)'))
        .to_h
    end

    def num_assists
      Goal
        .where(match_id: @match_ids, assist_id: @player_ids)
        .unscope(:order)
        .group(:assist_id)
        .pluck(Arel.sql('assist_id, COUNT(id)'))
        .to_h
    end

    def num_cs
      Performance
        .clean_sheets(@team)
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(performances.id)'))
        .to_h
    end

    def num_minutes
      num_minutes_query = 'SUM(performances.stop - performances.start)'
      Performance
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql("player_id, #{num_minutes_query}"))
        .to_h
    end

    def season_players
      PlayerHistory
        .where(player_id: @player_ids)
        .order(:datestamp)
        .group_by(&:player_id)
        .to_h
    end

    def match_results
      @team
        .matches
        .where(id: @match_ids)
        .group_by(&:competition).inject({}) do |h, (competition, matches)|
          h.merge(competition => matches_data(matches))
        end
    end

    def matches_data(matches)
      { wins: 0, draws: 0, losses: 0, gf: 0, ga: 0 }.tap do |data|
        matches.each do |match|
          next unless match.team_played?

          data[match.team_result.pluralize.to_sym] += 1
          data[:gf] += match.team_score
          data[:ga] += match.other_score
        end
      end
    end
end
