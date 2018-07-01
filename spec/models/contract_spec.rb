# == Schema Information
#
# Table name: contracts
#
#  id                :integer          not null, primary key
#  player_id         :integer
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

  it 'requires a signed date' do
    expect(FactoryBot.build(:contract, signed_date: nil)).to_not be_valid
  end

  it 'requires a start date' do
    expect(FactoryBot.build(:contract, start_date: nil)).to_not be_valid
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

  it 'provides all three fields for a performance bonus' do
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract, bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to be_valid
  end

  it 'has no origin if youth' do
    expect(FactoryBot.build(:contract, youth: true, origin: Faker::Team.name)).to_not be_valid
  end

  it 'is not loan and youth' do
    expect(FactoryBot.build(:contract, youth: true, loan: true)).to_not be_valid
  end

  it 'has the same origin and destination if on loan' do
    expect(FactoryBot.build(:contract, loan: true, origin: Faker::Team.unique.name, destination: Faker::Team.unique.name)).to_not be_valid
  end

  it 'has an initial contract history record' do
    expect(contract.contract_histories.length).to be == 1
  end

  it 'records compensation changes in history' do
    contract.update(wage: Faker::Number.unique.between(1_000, 1_000_000))
    contract.update(wage: Faker::Number.unique.between(1_000, 1_000_000))
    expect(contract.contract_histories.length).to be == 3
    expect(contract.contract_histories.last.wage).to be == contract.wage

    contract.update(end_date: Faker::Date.forward(730))
    expect(contract.contract_histories.last.end_date).to be == contract.end_date

    contract.update(signing_bonus: Faker::Number.between(2_000, 20_000_000))
    expect(contract.contract_histories.last.signing_bonus).to be == contract.signing_bonus

    contract.update(release_clause: Faker::Number.between(200_000, 200_000_000))
    expect(contract.contract_histories.last.release_clause).to be == contract.release_clause

    contract.update(bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)
    expect(contract.contract_histories.last.bonus_req).to be == contract.bonus_req
    expect(contract.contract_histories.last.performance_bonus).to be == contract.performance_bonus
    expect(contract.contract_histories.last.bonus_req_type).to be == contract.bonus_req_type
  end  
end
