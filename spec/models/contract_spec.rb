# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint(8)        not null, primary key
#  player_id         :bigint(8)
#  signed_date       :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  end_date          :date
#  effective_date    :date
#
# Indexes
#
#  index_contracts_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Contract, type: :model do
  let(:contract) { FactoryBot.create(:contract) }
  let(:perf_bonus) { Faker::Number.between(10_000, 1_000_000) }
  let(:bonus_req) { Faker::Number.between(1, 25) }
  let(:bonus_req_type) { Contract::BONUS_REQUIREMENT_TYPES.sample }

  it "has a valid factory" do
    expect(contract).to be_valid
  end

  it 'requires an effective date' do
    expect(FactoryBot.build(:contract, effective_date: nil)).to_not be_valid
  end

  it 'requires an end date' do
    expect(FactoryBot.build(:contract, end_date: nil)).to_not be_valid
  end

  it 'requires a wage' do
    expect(FactoryBot.build(:contract, wage: nil)).to_not be_valid
  end

  it 'has a valid bonus requirement type if present' do
    expect(FactoryBot.build(:contract, bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: Faker::Lorem.word)).to_not be_valid
  end

  it 'sets Player as Pending if effective_date > current date' do
    future_date = Faker::Date.between(1.days.from_now, 365.days.from_now)
    contract = FactoryBot.create :contract, effective_date: future_date
    expect(contract.player.status).to be == 'Pending'
  end

  it 'sets Pending Player as Active once current date reaches effective date' do
    future_date = Faker::Date.between(1.days.from_now, 365.days.from_now)
    contract = FactoryBot.create :contract, effective_date: future_date
    contract.player.team.update(current_date: future_date)
    expect(contract.player.reload.active?).to be == true
  end

  it 'sets new Player as Active if effective date < current date' do
    player = FactoryBot.create :player, contracts_count: 0
    FactoryBot.create :contract, player: player
    expect(player.active?).to be true
  end

  it 'sets Active Player as Inactive once contract expires' do
    player = FactoryBot.create :player
    player.contracts.last.update(end_date: 1.day.from_now)
    player.team.increment_date(1.week)
    player.reload
    expect(player.active?).to be_falsey
  end

  it 'provides all three fields for a performance bonus' do
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to be_valid
  end

  it 'ends tracking of any injuries upon expiration' do
    @player = FactoryBot.create(:player)
    FactoryBot.create :contract,
                      player: @player,
                      effective_date: @player.current_date,
                      end_date: @player.current_date + 1.week
    FactoryBot.create :injury, player: @player
    @player.team.increment_date 1.week
    @player.reload
    expect(@player.injured?).to be false
    expect(@player.injuries.last.end_date).to be == @player.current_date
  end
end
