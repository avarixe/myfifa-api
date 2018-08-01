# == Schema Information
#
# Table name: transfers
#
#  id             :bigint(8)        not null, primary key
#  player_id      :bigint(8)
#  signed_date    :date
#  effective_date :date
#  origin         :string
#  destination    :string
#  fee            :integer
#  traded_player  :string
#  addon_clause   :integer
#  loan           :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Transfer, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:transfer)).to be_valid
  end

  it 'requires an origin' do
    expect(FactoryBot.build(:transfer, origin: nil)).to_not be_valid
  end

  it 'requires a destination' do
    expect(FactoryBot.build(:transfer, destination: nil)).to_not be_valid
  end

  it 'has a valid add-on clause if any' do
    expect(FactoryBot.build(:transfer, addon_clause: -1)).to_not be_valid
  end

  it 'is signed on the team current date' do
    transfer = FactoryBot.create(:transfer)
    expect(transfer.signed_date).to be == transfer.team.current_date
  end
end
