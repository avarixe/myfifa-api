# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  minute      :integer
#  player_name :string
#  red_card    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  match_id    :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_bookings_on_match_id   (match_id)
#  index_bookings_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:booking) { FactoryBot.create(:booking) }

  it "has a valid factory" do
    expect(booking).to be_valid
  end

  it 'requires a valid minute' do
    expect(FactoryBot.build(:booking, minute: nil)).to_not be_valid
    expect(FactoryBot.build(:booking, minute: -1)).to_not be_valid
  end

  it 'requires a Cap for the player'

  it 'automatically sets player name if player_id set' do
    player = FactoryBot.create(:player)
    player_booking = FactoryBot.create :booking, player_id: player.id
    expect(player_booking.player_name).to be == player.name
  end

  it 'changes player name if player_id changed' do
    player = FactoryBot.create :player
    player2 = FactoryBot.create :player, team: player.team
    player_booking = FactoryBot.create :booking, player_id: player.id
    player_booking.update(player_id: player2.id)
    expect(player_booking.player_name).to be == player2.name
  end
end
