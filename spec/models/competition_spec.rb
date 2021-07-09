# == Schema Information
#
# Table name: competitions
#
#  id         :bigint           not null, primary key
#  champion   :string
#  name       :string
#  season     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint
#
# Indexes
#
#  index_competitions_on_season   (season)
#  index_competitions_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Competition, type: :model do
  let(:competition) { create(:competition) }

  it 'has a valid factory' do
    expect(competition).to be_valid
  end

  it 'requires a season' do
    expect(build(:competition, season: nil)).to_not be_valid
  end

  it 'requires a name' do
    expect(build(:competition, name: nil)).to_not be_valid
  end

  it 'rejects invalid preset formats' do
    expect(build(:competition, preset_format: 'Wrong')).to_not be_valid
  end

  it 'requires a num_team if League' do
    expect(build(:league, num_teams: nil)).to_not be_valid
    expect(build(:league, num_teams: 1)).to_not be_valid
  end

  it 'rejects invalid Knockout settings' do
    expect(build(:cup, num_teams: nil)).to_not be_valid
    expect(build(:cup, num_teams: 14)).to_not be_valid
  end

  it 'rejects invalid Group + Knockout settings' do
    %i[
      num_teams
      num_teams_per_group
      num_advances_from_group
    ].each do |preset_attr|
      expect(build(:tournament, preset_attr => nil)).to_not be_valid
      expect(build(:tournament, preset_attr => 0)).to_not be_valid
    end

    presets = [
      { expect_valid: true,  params: { num_teams: 32, num_teams_per_group: 4, num_advances_from_group: 2 } },
      { expect_valid: true,  params: { num_teams:  8, num_teams_per_group: 4, num_advances_from_group: 2 } },
      { expect_valid: true,  params: { num_teams: 24, num_teams_per_group: 3, num_advances_from_group: 2 } },
      { expect_valid: false, params: { num_teams: 32, num_teams_per_group: 6, num_advances_from_group: 2 } },
      { expect_valid: false, params: { num_teams: 30, num_teams_per_group: 6, num_advances_from_group: 2 } }
    ]

    presets.each do |preset|
      if preset[:expect_valid]
        expect(build(:tournament, preset[:params])).to be_valid
      else
        expect(build(:tournament, preset[:params])).to_not be_valid
      end
    end
  end

  it 'loads League Table' do
    num_teams = Faker::Number.between(from: 2, to: 30).to_i
    league = create(:league, num_teams: num_teams)
    expect(league.stages.count).to be == 1

    table = league.stages.first
    expect(table.table_rows.size).to be == num_teams
  end

  it 'loads Knockout stages' do
    num_rounds = Faker::Number.between(from: 1, to: 6).to_i
    num_teams = 2**num_rounds

    cup = create(:cup, num_teams: num_teams)
    rounds = cup.stages.includes(:fixtures)

    expect(rounds.size).to be == num_rounds
    rounds.each_with_index do |round, i|
      num_round_teams = num_teams / 2**i
      expect(round.fixtures.size).to be == num_round_teams / 2
    end
  end


  it 'loads Group + Knockout stages' do
    presets = [
      { num_teams: 32, num_teams_per_group: 4, num_advances_from_group: 2 },
      { num_teams:  8, num_teams_per_group: 4, num_advances_from_group: 2 },
      { num_teams: 24, num_teams_per_group: 3, num_advances_from_group: 2 },
    ]

    presets.each do |preset|

      num_groups = preset[:num_teams] / preset[:num_teams_per_group]
      tournament = create(:tournament, preset)
      tables = tournament.stages.includes(:table_rows).where(table: true)

      expect(tables.size).to be == num_groups
      tables.each do |table|
        expect(table.table_rows.size).to be == preset[:num_teams_per_group]
      end

      num_rounds = Math.log(num_groups * preset[:num_advances_from_group], 2).to_i
      rounds = tournament.stages.includes(:fixtures).where(table: false)

      expect(rounds.size).to be == num_rounds
      rounds.each_with_index do |round, i|
        num_round_teams = num_groups * preset[:num_advances_from_group] / 2**i
        expect(round.fixtures.size).to be == num_round_teams / 2
      end
    end
  end
end
