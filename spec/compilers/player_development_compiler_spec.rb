# frozen_string_literal: true

require 'rails_helper'

describe PlayerDevelopmentCompiler do
  let(:team) { Team.last }

  it 'requires a team' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'result' do
    sample_set = (0...Faker::Number.within(range: 5..10)).map do
      {
        ovr: (0..3).map { Faker::Number.within(range: 50..90) },
        value: (0..3).map { Faker::Number.within(range: 50_000..9_000_000) }
      }
    end

    before :all do
      team = create :team
      sample_set.each do |set|
        team.update currently_on: team.started_on
        player = create :player,
                        team: team,
                        ovr: set[:ovr][0],
                        value: set[:value][0],
                        contracts_count: 0
        create :contract,
               player: player,
               ended_on: team.end_of_season(5)
        set[:player] = player
        3.times do |i|
          team.update currently_on: team.started_on +
                                    i.years +
                                    Faker::Number.within(range: 1..11).months
          set[:player].update ovr: set[:ovr][i + 1], value: set[:value][i + 1]
        end
      end
    end

    after :all do
      User.last.destroy
    end

    it 'filters results by Player ID if provided' do
      sample_set.each do |set|
        compiler = described_class.new(team: team, player_ids: [set[:player].id])
        compiler.results.each do |result|
          expect(result[:player_id]).to be == set[:player].id
        end
      end
    end

    it 'only provides Player ovr/value changes for Season if provided' do
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results
        sample_set.each do |set|
          expected_data = {
            season: season,
            player_id: set[:player].id,
            ovr: [set[:ovr][season], set[:ovr][season + 1]],
            value: [set[:value][season], set[:value][season + 1]]
          }
          expect(results).to include(expected_data)
        end
      end
    end

    it 'will not include Players not active during a Season if provided' do
      team.update currently_on: team.started_on
      player = create :player, team: team
      create :contract,
             player: player,
             started_on: team.started_on,
             ended_on: team.end_of_season(1)
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        player_results = compiler.results.find do |result|
          result[:player_id] == player.id
        end
        expecting = expect(player_results)
        if season < 2
          expecting.to be_present
        else
          expecting.not_to be_present
        end
      end
    end

    it 'provides Player ovr/value changes for all Seasons if provided' do
      compiler = described_class.new(team: team)
      (0..2).each do |season|
        results_include_season = compiler.results.any? do |result|
          result[:season] == season
        end
        expect(results_include_season).to be true
      end
    end
  end
end
