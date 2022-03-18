# frozen_string_literal: true

require 'rails_helper'

describe TeamDevelopmentCompiler do
  let(:team) { Team.last }

  it 'requires a team' do
    expect { described_class.new(season: 0) }.to raise_error(ArgumentError)
  end

  it 'requires a season' do
    expect { described_class.new(team: build(:team)) }.to raise_error(ArgumentError)
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
               signed_on: team.currently_on,
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

    it 'calculates the average Player OVR at season start' do
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results

        start_ovrs = sample_set.map { |set| set[:ovr][season] }
        expect(results[:start_ovr]).to be == start_ovrs.sum(0) / start_ovrs.size
      end
    end

    it 'calculates the average Player OVR at season end' do
      team.update currently_on: team.end_of_season(2)
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results

        end_ovrs = sample_set.map { |set| set[:ovr][season + 1] }
        expect(results[:end_ovr]).to be == end_ovrs.sum(0) / end_ovrs.size
      end
    end

    it 'calculates the total Player value at season start' do
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results

        start_values = sample_set.map { |set| set[:value][season] }
        expect(results[:start_value]).to be == start_values.sum(0)
      end
    end

    it 'calculates the total Player value at season end' do
      team.update currently_on: team.end_of_season(2)
      (0..2).each do |season|
        compiler = described_class.new(team: team, season: season)
        results = compiler.results

        end_values = sample_set.map { |set| set[:value][season + 1] }
        expect(results[:end_value]).to be == end_values.sum(0)
      end
    end
  end
end
