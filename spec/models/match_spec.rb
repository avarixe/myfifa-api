# frozen_string_literal: true

# == Schema Information
#
# Table name: matches
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  home        :string
#  away        :string
#  competition :string
#  played_on   :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  extra_time  :boolean          default(FALSE)
#  home_score  :integer
#  away_score  :integer
#  stage       :string
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:match) { FactoryBot.create :match }

  it 'has a valid factory' do
    expect(match).to be_valid
  end

  it 'requires a home team' do
    expect(FactoryBot.build(:match, home: nil)).to_not be_valid
  end

  it 'requires an away team' do
    expect(FactoryBot.build(:match, away: nil)).to_not be_valid
  end

  it 'requires a competition' do
    expect(FactoryBot.build(:match, competition: nil)).to_not be_valid
  end

  it 'cannot have duplicate home and away teams' do
    team = Faker::Team.name
    expect(FactoryBot.build(:match, home: team, away: team)).to_not be_valid
  end

  it 'defaults date to the Team current date' do
    @match = FactoryBot.create :match, played_on: nil
    expect(match.played_on).to be == match.team.currently_on
  end

  it 'detects when user team is playing' do
    team = FactoryBot.create(:team)
    expect(FactoryBot.build(:match).team_played?).to be false
    match1 = FactoryBot.build :match, team: team, home: team.title
    expect(match1.team_played?).to be true
    match2 = FactoryBot.build :match, team: team, away: team.title
    expect(match2.team_played?).to be true
  end

  it 'starts off 0 - 0' do
    expect(match.score).to be == '0 - 0'
  end

  it 'cannot have two Performance records for the same player' do
    @match = FactoryBot.create :match
    @player = FactoryBot.create :player, team: @match.team
    FactoryBot.create :cap, match: @match, player: @player
    expect(
      FactoryBot.build :cap,
                       match: @match,
                       player: @player
    ).to_not be_valid
  end

  it 'sets Match times to 120 minutes if extra time' do
    @player = FactoryBot.create :player, team: match.team
    cap = FactoryBot.create :cap, match: match, player: @player
    match.update(extra_time: true)
    expect(cap.reload.stop).to be == 120
    match.update(extra_time: false)
    expect(cap.reload.stop).to be == 90
  end

  it 'does not move current date forward if date is behind current date' do
    match.update(played_on: match.currently_on - 1.day)
    expect(match.team.reload.currently_on).to_not be == match.played_on
  end

  it 'moves current date forward if date is ahead of current date' do
    match.update(played_on: match.currently_on + 1.day)
    expect(match.team.reload.currently_on).to be == match.played_on
  end
end
