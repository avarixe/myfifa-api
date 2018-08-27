# == Schema Information
#
# Table name: matches
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  home        :string
#  away        :string
#  competition :string
#  date_played :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  extra_time  :boolean          default(FALSE)
#  home_score  :integer
#  away_score  :integer
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:match) { FactoryBot.create(:match) }

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

  it 'occurs on the Team current date' do
    expect(match.date_played).to be == match.team.current_date
  end

  it 'detects when user team is playing' do
    team = FactoryBot.create(:team)
    expect(FactoryBot.build(:match).team_played?).to be false
    expect(FactoryBot.build(:match, team: team, home: team.title).team_played?).to be true
    expect(FactoryBot.build(:match, team: team, away: team.title).team_played?).to be true
  end

  it 'starts off 0 - 0' do
    expect(match.score).to be == '0 - 0'
  end

  it 'cannot have two Performance records for the same player' do
    @match = FactoryBot.create :match
    @player = FactoryBot.create :player, team: @match.team
    FactoryBot.create :performance,
                      match: @match,
                      player: @player
    expect(FactoryBot.build(:performance, match: @match, player: @player)).to_not be_valid
  end
end
