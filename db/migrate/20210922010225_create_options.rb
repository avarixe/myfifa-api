class CreateOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :options do |t|
      t.references :user
      t.string :category
      t.string :value
    end

    add_index :options, %i[user_id category value], unique: true

    reversible do |dir|
      dir.up do
        User.all.each do |user|
          team_options = Team.from(compiled_query(user)).order(:name).pluck(:name).map do |name|
            { user_id: user.id, category: 'Team', value: name }
          end
          Option.insert_all(team_options) if team_options.any?
        end
      end
    end
  end

  private

    def compiled_query(user)
      <<~SQL.squish
        ( #{teams_query_sql(user)}
          UNION #{matches_query_sql(user, 'home')}
          UNION #{matches_query_sql(user, 'away')}
          UNION #{table_rows_query_sql(user)}
          UNION #{fixtures_query_sql(user, 'home_team')}
          UNION #{fixtures_query_sql(user, 'away_team')}
          UNION #{transfers_query_sql(user, 'origin')}
          UNION #{transfers_query_sql(user, 'destination')}
          UNION #{loans_query_sql(user, 'origin')}
          UNION #{loans_query_sql(user, 'destination')}
        ) AS teams
      SQL
    end

    def teams_query_sql(user)
      select_team_name_sql user, Team.all, 'name'
    end

    def matches_query_sql(user, column)
      select_team_name_sql user, Match.joins(:team), column
    end

    def table_rows_query_sql(user)
      select_team_name_sql(
        user,
        TableRow.unscope(:order).joins(stage: { competition: :team }),
        'table_rows.name'
      )
    end

    def fixtures_query_sql(user, column)
      select_team_name_sql user, Fixture.joins(stage: { competition: :team }), column
    end

    def transfers_query_sql(user, column)
      select_team_name_sql user, Transfer.joins(player: :team), column
    end

    def loans_query_sql(user, column)
      select_team_name_sql user, Loan.joins(player: :team), column
    end

    def select_team_name_sql(user, collection, column)
      collection
        .where.not(column => nil)
        .where(belongs_to_user(user))
        .select(column)
        .to_sql
    end

    def belongs_to_user(user)
      { teams: { user_id: user.id } }
    end
end
