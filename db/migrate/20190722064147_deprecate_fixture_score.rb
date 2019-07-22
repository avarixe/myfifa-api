class DeprecateFixtureScore < ActiveRecord::Migration[5.2]
  def up
    Stage.includes(:fixtures).each do |stage|
      matchups = {}

      # match up Fixtures to determine pre-existing sets of Legs
      stage.fixtures.each do |fixture|
        fixture_teams = [fixture.home_team, fixture.away_team]
        matchup = matchups[fixture_teams] || matchups[fixture_teams.reverse]

        if matchup
          matchup << fixture
        else
          matchups[fixture_teams] = [fixture]
        end
      end

      # for each matchup, attach Legs to the first Fixture and delete the others
      matchups.each do |teams, fixtures|
        fixture = fixtures.first

        fixtures.each_with_index do |leg, i|
          leg_attributes =
            if fixture.home_team == leg.home_team
              { home_score: leg.home_score, away_score: leg.away_score }
            else
              { home_score: leg.away_score, away_score: leg.home_score }
            end

          fixture.legs.create leg_attributes

          leg.destroy unless i.zero?
        end
      end
    end

    remove_column :fixtures, :home_score
    remove_column :fixtures, :away_score
  end

  def down
    add_column :fixtures, :home_score, :string
    add_column :fixtures, :away_score, :string

    Fixture.includes(:legs).each do |fixture|
      fixture.update home_score: fixture.legs.first.home_score,
                     away_score: fixture.legs.first.away_score

      fixture.legs.pop(1).each do |leg|
        Fixture.create home_team: fixture.away_team,
                       away_team: fixture.home_team,
                       home_score: leg.away_score,
                       away_score: leg.home_score
      end

      fixture.legs.delete_all
    end
  end
end
