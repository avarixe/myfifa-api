# frozen_string_literal: true

require 'rails_helper'

describe TeamNamesCompiler do
  it 'requires a User' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'result' do
    let(:user) { create :user }
    let(:compiler) { described_class.new(user: user) }

    it 'returns names entered by all Teams for user' do
      teams = create_list :team, 3, user: user
      expect(compiler.results).to match_array(teams.map(&:name).uniq)
    end

    it 'returns all Match team names entered by user' do
      teams = create_list :team, 3, user: user
      matches = (0...3).map do
        create :match,
               team: teams.sample,
               home: Faker::Team.name,
               away: "#{Faker::Team.name} B"
      end
      matches.each do |match|
        expect(compiler.results).to include(match.home, match.away)
      end
    end

    it 'returns all Table Row teams entered by user' do
      teams = create_list :team, 3, user: user
      competitions = create_list :competition, 3, team: teams.sample
      stages = create_list :stage, 5, competition: competitions.sample
      rows = create_list :table_row, 10, stage: stages.sample
      expect(compiler.results).to include(*rows.map(&:name).uniq)
    end

    it 'returns all Fixture teams entered by user' do
      teams = create_list :team, 3, user: user
      competitions = create_list :competition, 3, team: teams.sample
      stages = create_list :stage, 5, competition: competitions.sample
      fixtures = create_list :fixture, 10, stage: stages.sample
      fixtures.each do |fixture|
        expect(compiler.results).to include(fixture.home_team, fixture.away_team)
      end
    end

    it 'returns all Transfer origins and destinations' do
      teams = create_list :team, 3, user: user
      players = create_list :player, 3, team: teams.sample
      transfers = create_list :transfer, 3, player: players.sample
      transfers.each do |transfer|
        expect(compiler.results).to include(transfer.origin, transfer.destination)
      end
    end

    it 'returns all Loan origins and destinations' do
      teams = create_list :team, 3, user: user
      players = create_list :player, 3, team: teams.sample
      loans = create_list :loan, 3, player: players.sample
      loans.each do |loan|
        expect(compiler.results).to include(loan.origin, loan.destination)
      end
    end

    it 'does not return results entered by a different User' do
      create_list :team, 3, user: user
      team = create :team, name: "#{Faker::Team.name} B"
      expect(compiler.results).not_to include(team.name)
    end

    it 'does not return any duplicate names' do
      teams = create_list :team, 3, user: user, name: Faker::Team.name
      expect(compiler.results).to match_array([teams[0].name])
    end

    it 'does not include blank values' do
      team = create :team, user: user
      competition = create :competition, team: team
      stage = create :stage, competition: competition
      create :fixture, stage: stage, home_team: nil
      expect(compiler.results).not_to include(nil)
    end

    it 'filters results when provided' do
      team = create :team, user: user
      create_list :team, 5, user: user
      expect(described_class.new(user: user, search: team.name.upcase).results)
        .to match_array([team.name])
    end
  end
end
