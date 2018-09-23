# frozen_string_literal: true

# == Schema Information
#
# Table name: squads
#
#  id             :bigint(8)        not null, primary key
#  team_id        :bigint(8)
#  name           :string
#  players_list   :text             default([]), is an Array
#  positions_list :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Squad, type: :model do
  let(:squad) { FactoryBot.create(:squad) }

  it "has a valid factory" do
    expect(squad).to be_valid
  end

  it 'requires 11 players' do
    [
      Faker::Number.between(0, 10),
      Faker::Number.between(12, 20)
    ].each do |i|
      team = FactoryBot.create(:team_with_players, players_count: i)
      squad = FactoryBot.build(:squad, team: team)
      expect(squad).to_not be_valid
    end
  end

  it 'requires 11 positions' do
    [
      Faker::Number.between(0, 10),
      Faker::Number.between(12, 20)
    ].each do |i|
      squad = FactoryBot.build(:squad, positions_list: (1..i).map { |j| Performance::POSITIONS.sample })
      expect(squad).to_not be_valid
    end
  end

  it 'requires valid positions' do
    squad.positions_list[0] = Faker::Lorem.word
    expect(squad).to_not be_valid
  end

  it 'requires valid player ids' do
    squad = FactoryBot.build(:squad, players_list: (1..11).map { |j| Faker::Number.number(4) })
    expect(squad).to_not be_valid
  end

  it 'cannot have duplicate player ids' do
    squad = FactoryBot.build(:squad)
    squad.players_list[1] = squad.players_list[0]
    expect(squad).to_not be_valid
  end
end
