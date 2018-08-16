class StatisticsController < APIController
  load_and_authorize_resource :team
  before_action :set_player_ids
  before_action :set_match_ids

  def index
    render json: {
      player_ids:  @player_ids,
      num_games:   num_games,
      num_goals:   num_goals,
      num_assists: num_assists,
      num_cs:      num_cs,
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

    def num_games
      Performance
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(id) AS num_games'))
        .to_h
    end

    def num_goals
      Goal
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(id) AS num_goals'))
        .to_h
    end

    def num_assists
      Goal
        .where(match_id: @match_ids, assist_id: @player_ids)
        .unscope(:order)
        .group(:assist_id)
        .pluck(Arel.sql('assist_id, COUNT(id) AS num_assists'))
        .to_h
    end

    def num_cs
      Performance
        .clean_sheets(@team)
        .where(match_id: @match_ids, player_id: @player_ids)
        .unscope(:order)
        .group(:player_id)
        .pluck(Arel.sql('player_id, COUNT(performances.id) AS num_cs'))
        .to_h
    end

    def stat_params
      params
        .fetch(:query, {})
        .permit(player_ids: [], match_ids: [])
    end
end
