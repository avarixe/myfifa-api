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

  it 'requires 11 positions' do
    [
      Faker::Number.between(0, 10),
      Faker::Number.between(12, 20)
    ].each do |i|
      squad = FactoryBot.build :squad, players_count: i
      expect(squad).to_not be_valid
    end
  end

  it 'cannot have duplicate positions' do
    squad = FactoryBot.build :squad, players_count: 10
    taken_positions = squad.squad_players.map(&:pos)
    squad.squad_players << FactoryBot.build(:squad_player, pos: taken_positions[0])
    expect(squad).to_not be_valid
  end

  it 'cannot have duplicate player ids' do
    squad = FactoryBot.build :squad, players_count: 10
    taken_player_ids = squad.squad_players.map(&:player_id)
    squad.squad_players << FactoryBot.build(:squad_player, player_id: taken_player_ids[0])
    expect(squad).to_not be_valid
  end
end
