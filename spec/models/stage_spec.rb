# == Schema Information
#
# Table name: stages
#
#  id             :bigint           not null, primary key
#  name           :string
#  num_fixtures   :integer
#  num_teams      :integer
#  table          :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competition_id :bigint
#
# Indexes
#
#  index_stages_on_competition_id  (competition_id)
#

require 'rails_helper'

RSpec.describe Stage, type: :model do
  let(:stage) { FactoryBot.create(:stage) }

  it 'has a valid factory' do
    expect(stage).to be_valid
  end

  it 'requires a num_team' do
    expect(FactoryBot.build(:stage, num_teams: nil)).to_not be_valid
    expect(FactoryBot.build(:stage, num_teams: Faker::Number.negative)).to_not be_valid
  end

  it 'requires a num_fixtures' do
    expect(FactoryBot.build(:stage, num_fixtures: nil)).to_not be_valid
    expect(FactoryBot.build(:stage, num_fixtures: Faker::Number.negative)).to_not be_valid
  end

  it 'sets default name depending on number of teams' do
    expect(Stage.new(num_teams: 8).name).to be == 'Quarter-Finals'
    expect(Stage.new(num_teams: 4).name).to be == 'Semi-Finals'
    expect(Stage.new(num_teams: 2).name).to be == 'Final'
    num_teams = Faker::Number.between(from: 9, to: 20)
    expect(Stage.new(num_teams: num_teams).name).to be == "Round of #{num_teams}"
  end

  it 'creates table rows if table' do
    stage = FactoryBot.create(:stage, table: true)
    expect(stage.table_rows.size).to be == stage.num_teams
    expect(stage.fixtures.size).to be == 0
  end

  it 'creates fixtures if round' do
    expect(stage.table_rows.size).to be == 0
    expect(stage.fixtures.size).to be == stage.num_fixtures
  end
end
