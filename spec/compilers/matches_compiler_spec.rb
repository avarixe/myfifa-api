# frozen_string_literal: true

require 'rails_helper'

describe MatchesCompiler do
  let(:team) { Team.first }

  sample_competitions = (0..2).map { Faker::Sports::Football.competition }
  sample_stages = (0..2).map { |i| "Round #{i}" }
  sample_set = (0...Faker::Number.within(range: 5..10)).map do
    {
      season: Faker::Number.within(range: 0..3),
      competition: sample_competitions.sample,
      stage: sample_stages.sample,
      home_score: rand(0..1),
      away_score: rand(0..1),
      home: Faker::Boolean.boolean
    }
  end

  before :all do
    team = create(:team)
    sample_set.each do |set|
      create(:match,
             team:,
             home: set[:home] ? team.name : 'Home Team',
             away: set[:home] ? 'Away Team' : team.name,
             home_score: set[:home_score],
             away_score: set[:away_score],
             competition: set[:competition],
             stage: set[:stage],
             played_on: team.started_on + set[:season].years)
    end
  end

  after :all do
    User.last.destroy
  end

  it 'requires a team' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  it 'returns set of Matches' do
    compiler = described_class.new(team:)
    expect(compiler.results).to match_array(Match.all.to_a)
  end

  it 'returns total of Matches' do
    compiler = described_class.new(team:)
    expect(compiler.total).to be == Match.count
  end

  it 'offsets by page' do
    compiler = described_class.new(team:, pagination: { items_per_page: 3, page: 1 })
    expect(compiler.results).to be == team.matches.offset(3).limit(3).to_a
  end

  it 'limits by items per page' do
    compiler = described_class.new(team:, pagination: { items_per_page: 3, page: 0 })
    expect(compiler.results.size).to be == 3
  end

  it 'sorts Matches' do
    compiler = described_class.new(team:, pagination: { sort_by: 'played_on', sort_desc: true })
    expect(compiler.results.to_a).to be == Match.order(played_on: :desc).to_a
  end

  it 'filters results by Season' do
    4.times do |season|
      compiler = described_class.new(team:, filters: { season: })
      expect(compiler.results.to_a).to be == team.matches.where(season:).to_a
    end
  end

  it 'filters results by Competition' do
    sample_competitions.each do |competition|
      compiler = described_class.new(team:, filters: { competition: })
      expect(compiler.results.to_a).to be == team.matches.where(competition:).to_a
    end
  end

  it 'filters results by Stage' do
    sample_stages.each do |stage|
      compiler = described_class.new(team:, filters: { stage: stage.gsub('Stage ', '') })
      expect(compiler.results.to_a).to be == team.matches.where(stage:).to_a
    end
  end

  it 'filters results by Home Team' do
    compiler = described_class.new(team:, filters: { team: 'Home' })
    expect(compiler.results.to_a).to be == team.matches.where(home: 'Home Team').to_a
  end

  it 'filters results by Away Team' do
    compiler = described_class.new(team:, filters: { team: 'Away' })
    expect(compiler.results.to_a).to be == team.matches.where(away: 'Away Team').to_a
  end

  it 'filters results by Wins' do
    compiler = described_class.new(team:, filters: { result: %w[win] })
    expect(compiler.results.to_a).to match_array(
      team.matches.to_a.select { |match| match.team_result == 'win' }
    )
  end

  it 'filters results by Draws' do
    compiler = described_class.new(team:, filters: { result: %w[draw] })
    expect(compiler.results.to_a).to match_array(
      team.matches.to_a.select { |match| match.team_result == 'draw' }
    )
  end

  it 'filters results by Losses' do
    compiler = described_class.new(team:, filters: { result: %w[loss] })
    expect(compiler.results.to_a).to match_array(
      team.matches.to_a.select { |match| match.team_result == 'loss' }
    )
  end

  it 'allows multiple result filters' do
    compiler = described_class.new(team:, filters: { result: %w[win draw loss] })
    expect(compiler.results.to_a).to be == team.matches.to_a
  end

  it 'filters by date' do
    compiler = described_class.new(
      team:,
      filters: { start_on: team.started_on + 1.year, end_on: team.started_on + 2.years }
    )
    expect(compiler.results.to_a).to be == (
      team.matches.where(played_on: team.started_on + 1.year..team.started_on + 2.years).to_a
    )
  end
end
