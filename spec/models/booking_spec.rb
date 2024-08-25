# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  home        :boolean          default(FALSE), not null
#  minute      :integer
#  player_name :string
#  red_card    :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cap_id      :bigint
#  match_id    :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_bookings_on_cap_id     (cap_id)
#  index_bookings_on_match_id   (match_id)
#  index_bookings_on_player_id  (player_id)
#

require 'rails_helper'

describe Booking do
  let(:booking) { create(:booking) }

  it 'has a valid factory' do
    expect(booking).to be_valid
  end

  it 'requires a minute' do
    expect(build(:booking, minute: nil)).not_to be_valid
  end

  it 'automatically sets player id if cap_id set' do
    player = create(:player)
    cap = create(:cap, player:)
    player_booking = create(:booking, cap_id: cap.id)
    expect(player_booking.player_id).to eq player.id
  end

  it 'automatically sets player name if cap_id set' do
    player = create(:player)
    cap = create(:cap, player:)
    player_booking = create(:booking, cap_id: cap.id)
    expect(player_booking.player_name).to eq player.name
  end

  it 'changes player id if cap_id changed' do
    player = create(:player)
    player2 = create(:player, team: player.team)
    player_booking = create(:booking, cap: create(:cap, player:))
    player_booking.update(cap: create(:cap, player: player2))
    expect(player_booking.player_id).to eq player2.id
  end

  it 'changes player name if cap_id changed' do
    player = create(:player)
    player2 = create(:player, team: player.team)
    player_booking = create(:booking, cap: create(:cap, player:))
    player_booking.update(cap: create(:cap, player: player2))
    expect(player_booking.player_name).to eq player2.name
  end
end
