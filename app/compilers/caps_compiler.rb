# frozen_string_literal: true

class CapsCompiler
  attr_accessor :player, :results, :total, :pagination, :filters

  def initialize(player:, pagination: {}, filters: {})
    @player = player
    @pagination = pagination
    @filters = filters

    @results = player.caps.joins(:match)
    filter_results
    @total = @results.count
    sort_results
    paginate_results
  end

  private

    def paginate_results
      items_per_page = pagination[:items_per_page]
      page = pagination[:page]
      @results = @results
                 .limit(items_per_page)
                 .offset(page.to_i * items_per_page.to_i)
    end

    def sort_results
      sort_by = pagination[:sort_by]&.underscore
      return if %w[played_on].exclude? sort_by

      sort_dir = pagination[:sort_desc] ? 'desc' : 'asc'
      @results = @results.unscope(:order).order(sort_by => sort_dir)
    end

    def filter_results
      filter_by(:season)
      filter_by(:competition)
      filter_by_like(:stage)
      filter_by_team
      filter_by_result
      filter_by_date
    end

    def filter_by(attribute)
      return if filters[attribute].blank?

      @results = @results.where(matches: { attribute => filters[attribute] })
    end

    def filter_by_like(attribute)
      return if filters[attribute].blank? || %i[stage].exclude?(attribute)

      @results = @results.where(
        Match.arel_table[attribute].matches("%#{Match.sanitize_sql_like(filters[attribute])}%")
      )
    end

    def filter_by_team
      return if filters[:team].blank?

      @results = @results.where(
        'matches.home ILIKE :team OR matches.away ILIKE :team',
        team: "%#{filters[:team]}%"
      )
    end

    def filter_by_result
      return if filters[:result].blank?

      @results = filters[:result].map do |match_result|
        @results.joins(player: :team).where(match_result_condition(match_result))
      end.reduce(&:or)
    end

    def filter_by_date
      @results = @results.where(matches: { played_on: filters[:start_on]..filters[:end_on] })
    end

    def match_result_condition(match_result)
      case match_result
      when 'win'
        <<~SQL.squish
          (teams.name = matches.home AND home_score > away_score) OR
          (teams.name = matches.away AND home_score < away_score)
        SQL
      when 'draw'
        'home_score = away_score'
      when 'loss'
        <<~SQL.squish
          (teams.name = matches.home AND home_score < away_score) OR
          (teams.name = matches.away AND home_score > away_score)
        SQL
      end
    end
end
