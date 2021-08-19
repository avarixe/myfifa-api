# frozen_string_literal: true

class TeamNamesCompiler
  include ActiveRecord::Sanitization::ClassMethods

  attr_accessor :user, :search

  def initialize(user:, search: nil)
    @user = user
    @search = search&.downcase
  end

  def results
    @results ||= Team.from(compiled_query).order(:name).pluck(:name)
  end

  private

    def compiled_query
      <<~SQL.squish
        ( #{teams_query_sql}
          UNION #{matches_query_sql('home')}
          UNION #{matches_query_sql('away')}
          UNION #{table_rows_query_sql}
          UNION #{fixtures_query_sql('home_team')}
          UNION #{fixtures_query_sql('away_team')}
          UNION #{transfers_query_sql('origin')}
          UNION #{transfers_query_sql('destination')}
          UNION #{loans_query_sql('origin')}
          UNION #{loans_query_sql('destination')}
        ) AS teams
      SQL
    end

    def teams_query_sql
      select_team_name_sql Team.all, 'name'
    end

    def matches_query_sql(column)
      select_team_name_sql Match.joins(:team), column
    end

    def table_rows_query_sql
      select_team_name_sql(
        TableRow.unscope(:order).joins(stage: { competition: :team }),
        'table_rows.name'
      )
    end

    def fixtures_query_sql(column)
      select_team_name_sql Fixture.joins(stage: { competition: :team }), column
    end

    def transfers_query_sql(column)
      select_team_name_sql Transfer.joins(player: :team), column
    end

    def loans_query_sql(column)
      select_team_name_sql Loan.joins(player: :team), column
    end

    def select_team_name_sql(collection, column)
      collection =
        if search.present?
          collection.where(
            sanitize_sql("LOWER(#{column}) LIKE ?"),
            "%#{search}%"
          )
        else
          collection.where.not(column => nil)
        end
      collection.where(belongs_to_user).select(column).to_sql
    end

    def belongs_to_user
      { teams: { user_id: user.id } }
    end
end
