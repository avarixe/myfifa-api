# frozen_string_literal: true

require 'rails_helper'

describe CapsCompiler do
  let!(:player) { Player.first }

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
    player = create(:player)
    team = player.team
    sample_set.each do |set|
      match = create(:match,
                     team:,
                     home: set[:home] ? team.name : 'Home Team',
                     away: set[:home] ? 'Away Team' : team.name,
                     home_score: set[:home_score],
                     away_score: set[:away_score],
                     competition: set[:competition],
                     stage: set[:stage],
                     played_on: team.started_on + set[:season].years)
      create(:cap, match:, player:)
    end
  end

  after :all do
    User.last.destroy
  end

  it 'requires a player' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  it 'returns set of Caps' do
    compiler = described_class.new(player:)
    expect(compiler.results).to match_array(Cap.all.to_a)
  end

  it 'returns total of Caps' do
    compiler = described_class.new(player:)
    expect(compiler.total).to be == Cap.count
  end

  it 'offsets by page' do
    compiler = described_class.new(player:, pagination: { items_per_page: 3, page: 1 })
    expect(compiler.results).to be == player.caps.offset(3).limit(3).to_a
  end

  it 'limits by items per page' do
    compiler = described_class.new(player:, pagination: { items_per_page: 3, page: 0 })
    expect(compiler.results.size).to be == 3
  end

  it 'sorts Matches' do
    compiler = described_class.new(player:, pagination: { sort_by: 'played_on', sort_desc: true })
    expect(compiler.results.to_a)
      .to be == Cap.joins(:match).order('matches.played_on' => :desc).to_a
  end

  it 'filters results by Season' do
    4.times do |season|
      compiler = described_class.new(player:, filters: { season: })
      expect(compiler.results.to_a)
        .to be == player.caps.joins(:match).where(matches: { season: }).to_a
    end
  end

  it 'filters results by Competition' do
    sample_competitions.each do |competition|
      compiler = described_class.new(player:, filters: { competition: })
      expect(compiler.results.to_a)
        .to be == player.caps.joins(:match).where(matches: { competition: }).to_a
    end
  end

  it 'filters results by Stage' do
    sample_stages.each do |stage|
      compiler = described_class.new(player:, filters: { stage: stage.gsub('Stage ', '') })
      expect(compiler.results.to_a)
        .to be == player.caps.joins(:match).where(matches: { stage: }).to_a
    end
  end

  it 'filters results by Home Team' do
    compiler = described_class.new(player:, filters: { team: 'Home' })
    expect(compiler.results.to_a)
      .to be == player.caps.joins(:match).where(matches: { home: 'Home Team' }).to_a
  end

  it 'filters results by Away Team' do
    compiler = described_class.new(player:, filters: { team: 'Away' })
    expect(compiler.results.to_a)
      .to be == player.caps.joins(:match).where(matches: { away: 'Away Team' }).to_a
  end

  it 'filters results by Wins' do
    compiler = described_class.new(player:, filters: { result: %w[win] })
    expect(compiler.results.to_a).to match_array(
      player.caps.to_a.select { |cap| cap.match.team_result == 'win' }
    )
  end

  it 'filters results by Draws' do
    compiler = described_class.new(player:, filters: { result: %w[draw] })
    expect(compiler.results.to_a).to match_array(
      player.caps.to_a.select { |cap| cap.match.team_result == 'draw' }
    )
  end

  it 'filters results by Losses' do
    compiler = described_class.new(player:, filters: { result: %w[loss] })
    expect(compiler.results.to_a).to match_array(
      player.caps.to_a.select { |cap| cap.match.team_result == 'loss' }
    )
  end

  it 'allows multiple result filters' do
    compiler = described_class.new(player:, filters: { result: %w[win draw loss] })
    expect(compiler.results.to_a).to be == player.caps.to_a
  end

  it 'filters by date' do
    team = player.team
    start_on = team.started_on + 1.year
    end_on = team.started_on + 2.years
    compiler = described_class.new(player:, filters: { start_on:, end_on: })
    expect(compiler.results.to_a).to be == (
      player.caps.joins(:match).where(matches: { played_on: start_on..end_on }).to_a
    )
  end
end
