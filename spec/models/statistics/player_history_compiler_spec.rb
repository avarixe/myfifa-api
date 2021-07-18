# frozen_string_literal: true

require 'rails_helper'

describe Statistics::PlayerHistoryCompiler do
  let(:team) { create :team }

  it 'requires a team' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'result' do
    let(:sample_set) do
      (0...Faker::Number.within(range: 5..10)).map do
        player = create :player, team: team
        create :contract,
               player: player,
               started_on: team.started_on,
               ended_on: team.end_of_season(5)
        {
          player: player,
          ovr: [
            player.ovr,
            *(0..2).map { Faker::Number.within(range: 50..90) }
          ],
          value: [
            player.value,
            *(0..2).map { Faker::Number.within(range: 50_000..9_000_000) }
          ]
        }
      end
    end

    before do
      sample_set.each do |set|
        3.times do |i|
          team.update currently_on: team.started_on +
                                    i.years +
                                    Faker::Number.within(range: 1..11).months
          set[:player].update ovr: set[:ovr][i + 1], value: set[:value][i + 1]
        end
      end
    end

    it 'filters results by Player ID if provided' do
      sample_set.each do |set|
        compiler = described_class.new(team: team, player_ids: [set[:player].id])
        compiler.results.each do |result|
          expect(result[:player_id]).to be == set[:player].id
        end
      end
    end

    it 'provides Player ovr/value changes' do
      compiler = described_class.new(team: team)
      results = compiler.results
      sample_set.each do |set|
        expected_data = {
          player_id: set[:player].id,
          ovr: [set[:ovr][0], set[:ovr][-1]],
          value: [set[:value][0], set[:value][-1]]
        }
        expect(results).to include(expected_data)
      end
    end

    it 'only provides Player ovr/value changes for Season if provided' do
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results
        sample_set.each do |set|
          expected_data = {
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
        results = compiler.results
        player_results = compiler.results.find do |result|
          result[:player_id] == player.id
        end
        if season < 2
          expect(player_results).to be_present
        else
          expect(player_results).not_to be_present
        end
      end
    end
  end
end
