# frozen_string_literal: true

# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  injured    :boolean          default(FALSE), not null
#  ovr        :integer
#  pos        :string
#  rating     :integer
#  start      :integer          default(0)
#  stop       :integer          default(90)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  next_id    :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id                          (match_id)
#  index_caps_on_next_id                           (next_id)
#  index_caps_on_player_id                         (player_id)
#  index_caps_on_player_id_and_match_id_and_start  (player_id,match_id,start) UNIQUE
#  index_caps_on_pos_and_match_id_and_start        (pos,match_id,start) UNIQUE
#

require 'rails_helper'

describe Cap do
  let(:team) { create(:team) }
  let(:player) { create(:player, team:) }
  let(:match) { create(:match, team:) }
  let(:cap) { create(:cap, player:, match:) }

  it 'has a valid factory' do
    expect(create(:cap)).to be_valid
  end

  it 'requires a position' do
    expect(build(:cap, pos: nil)).not_to be_valid
  end

  it 'requires a player' do
    expect(build(:cap, player_id: nil)).not_to be_valid
  end

  it 'requires a start minute' do
    expect(build(:cap, start: nil)).not_to be_valid
  end

  it 'requires a stop minute' do
    expect(build(:cap, stop: nil)).not_to be_valid
  end

  it 'can not have a stop minute before the start minute' do
    expect(build(:cap, start: 46, stop: 45)).not_to be_valid
  end

  it 'only accepts Active players' do
    player = create(:player, contracts_count: 0)
    expect(build(:cap, player:)).not_to be_valid
  end

  it 'must be associated with a Player and Match of the same team' do
    other_team = create(:team)
    match = create(:match, team: other_team)
    expect(build(:cap, player:, match:)).not_to be_valid
  end

  it 'caches the Player OVR when created' do
    expect(cap.ovr).to be == cap.player.ovr
  end

  it 'caches the latest Player OVR when created' do
    player = create(:player, ovr: 60)
    3.times do
      player.team.increment_date 1.year
      player.ovr += 10
      player.save!
    end

    match = create(:match, team: player.team, played_on: player.team.currently_on)
    cap = create(:cap, player:, match:)

    expect(cap.ovr).to be == 90
  end

  it 'caches the Player old OVR when created in the past' do
    team = create(:team)
    player = create(:player, team:, ovr: 70)
    team.increment_date 1.month
    player.update(ovr: 71)
    match = create(:match, team:, played_on: team.currently_on - 1.month)
    cap = create(:cap, player:, match:)
    expect(cap.ovr).to be == 70
  end

  it 'updates the Player OVR cache when Player is changed' do
    other_player = create(:player, team: cap.player.team)
    cap.update player: other_player
    expect(cap.ovr).to be == other_player.ovr
  end

  it 'does not change OVR if Player changes after date' do
    team = create(:team)
    player = create(:player, team:, ovr: 70)
    match = create(:match, team:, played_on: team.currently_on)
    cap = create(:cap, player:, match:)
    team.increment_date 1.month
    player.update(ovr: 71)
    expect(cap.reload.ovr).to be == 70
  end

  it 'sets stop when next Cap is set' do
    create(:cap, previous: cap, start: 60)
    expect(cap.reload.stop).to be == 60
  end

  it 'sets stop to Match length when next Cap is removed' do
    next_cap = create(:cap, previous: cap, start: 60)
    next_cap.destroy
    expect(cap.reload.stop).to be == 90
  end

  it 'changes stop when next Cap changes start' do
    next_cap = create(:cap, previous: cap, start: 60, stop: 90)
    next_cap.update!(start: 75)
    expect(cap.reload.stop).to be == 75
  end

  it 'propagates Cap ratings between siblings' do
    next_cap = create(:cap,
                      previous: cap,
                      player_id: cap.player_id,
                      match_id: cap.match_id,
                      start: 60,
                      stop: 90)
    next_cap.update(rating: 5)
    expect(cap.reload.rating).to be == 5
  end
end
