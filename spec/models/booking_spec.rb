# == Schema Information
#
# Table name: bookings
#
#  id          :bigint(8)        not null, primary key
#  match_id    :bigint(8)
#  minute      :integer
#  player_id   :bigint(8)
#  red_card    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_name :string
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

  it 'requires a valid player name' do
    expect(FactoryBot.build(:booking, player_name: nil)).to_not be_valid
  end

  it 'automatically sets player name if player_id set' do
    player = FactoryBot.create(:player)
    player_booking = FactoryBot.create :booking, player: player
    expect(player_booking.player_name).to be == player.name
  end
end
