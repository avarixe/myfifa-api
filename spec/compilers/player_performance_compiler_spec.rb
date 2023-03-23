# frozen_string_literal: true

require 'rails_helper'

describe PlayerPerformanceCompiler do
  let(:team) { Team.last }
  let(:compiler) { described_class.new(team:) }
  let(:results) { compiler.results }

  it 'requires a team' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'result' do
    sample_competitions = (0..2).map { Faker::Sports::Football.competition }
    sample_set = (0...Faker::Number.within(range: 5..10)).map do
      {
        player: Faker::Number.within(range: 0..2),
        season: Faker::Number.within(range: 0..3),
        competition: sample_competitions.sample,
        num_minutes: Faker::Number.within(range: 60..90),
        num_goals: Faker::Number.within(range: 0..3),
        num_assists: Faker::Number.within(range: 0..3),
        avg_rating: Faker::Number.within(range: 1..5),
        clean_sheet: Faker::Boolean.boolean,
        home: Faker::Boolean.boolean
      }
    end

    before :all do
      team = create(:team)
      players = create_list(:player, 3, team:)
      sample_set.each do |set|
        set[:player] = players[set[:player]]
        match = create(:match,
                       team:,
                       home: set[:home] ? team.name : 'Home Team',
                       away: set[:home] ? 'Away Team' : team.name,
                       home_score: set[:clean_sheet] ? 0 : 1,
                       away_score: set[:clean_sheet] ? 0 : 1,
                       competition: set[:competition],
                       played_on: team.started_on + set[:season].years)
        create(:cap,
               match:,
               player: set[:player],
               start: 0,
               stop: set[:num_minutes],
               rating: set[:avg_rating])
        create_list(:goal,
                    set[:num_goals],
                    match:,
                    player: set[:player],
                    home: set[:home])
        create_list(:goal,
                    set[:num_assists],
                    match:,
                    assisting_player: set[:player],
                    home: set[:home])
      end
    end

    after :all do
      User.last.destroy
    end

    it 'filters results by Player ID if provided' do
      team.players.each do |player|
        compiler = described_class.new(team:, player_ids: [player.id])
        num_in_set = sample_set.count { |set| set[:player] == player }
        num_in_results = compiler.results.pluck(:num_matches).sum
        expect(num_in_results).to be == num_in_set
      end
    end

    it 'filters results by Competition if provided' do
      sample_competitions.each do |competition|
        compiler = described_class.new(team:, competition:)
        num_in_set = sample_set.count { |set| set[:competition] == competition }
        num_in_results = compiler.results.pluck(:num_matches).sum
        expect(num_in_results).to be == num_in_set
      end
    end

    it 'filters results by Season if provided' do
      4.times do |season|
        compiler = described_class.new(team:, season:)
        num_in_set = sample_set.count { |set| set[:season] == season }
        num_in_results = compiler.results.pluck(:num_matches).sum
        expect(num_in_results).to be == num_in_set
      end
    end

    it 'reports num matches per player/season/competition set' do
      team.players.each do |player|
        sample_competitions.each do |competition|
          4.times do |season|
            num_in_set = sample_set.count do |set|
              set[:player] == player &&
                set[:competition] == competition &&
                set[:season] == season
            end
            num_in_results = compiler.results.find do |result|
              result[:player_id] == player.id &&
                result[:competition] == competition &&
                result[:season] == season
            end&.dig(:num_matches) || 0
            expect(num_in_results).to be == num_in_set
          end
        end
      end
    end

    %w[num_minutes num_goals num_assists].each do |metric|
      it "reports #{metric} per player/season/competition set" do
        team.players.each do |player|
          sample_competitions.each do |competition|
            4.times do |season|
              num_in_set = sample_set.sum do |set|
                if set[:player] == player &&
                   set[:competition] == competition &&
                   set[:season] == season
                  set[metric.to_sym]
                else
                  0
                end
              end
              num_in_results = compiler.results.find do |result|
                result[:player_id] == player.id &&
                  result[:competition] == competition &&
                  result[:season] == season
              end&.dig(metric.to_sym) || 0
              expect(num_in_results).to be == num_in_set
            end
          end
        end
      end
    end

    it 'reports avg_rating per player/season/competition set' do
      team.players.each do |player|
        sample_competitions.each do |competition|
          4.times do |season|
            set_data = sample_set.select do |set|
              set[:player] == player &&
                set[:competition] == competition &&
                set[:season] == season
            end
            num_in_set =
              if set_data.any?
                set_data.sum { |data| data[:avg_rating] * data[:num_minutes] }.to_f /
                  set_data.sum { |data| data[:num_minutes] }
              else
                0
              end
            num_in_results = compiler.results.find do |result|
              result[:player_id] == player.id &&
                result[:competition] == competition &&
                result[:season] == season
            end&.dig(:avg_rating) || 0
            expect(num_in_results.round(3)).to be == num_in_set.round(3)
          end
        end
      end
    end

    it 'reports num clean sheets per player/season/competition set' do
      team.players.each do |player|
        sample_competitions.each do |competition|
          4.times do |season|
            num_in_set = sample_set.count do |set|
              set[:player] == player &&
                set[:competition] == competition &&
                set[:season] == season &&
                set[:clean_sheet]
            end
            num_in_results = compiler.results.find do |result|
              result[:player_id] == player.id &&
                result[:competition] == competition &&
                result[:season] == season
            end&.dig(:num_clean_sheets) || 0
            expect(num_in_results).to be == num_in_set
          end
        end
      end
    end
  end
end
