# == Schema Information
#
# Table name: contract_histories
#
#  id                :integer          not null, primary key
#  contract_id       :integer
#  datestamp         :date
#  end_date          :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_contract_histories_on_contract_id  (contract_id)
#

require 'rails_helper'

RSpec.describe ContractHistory, type: :model do
  let(:perf_bonus) { Faker::Number.between(10_000, 1_000_000) }
  let(:bonus_req) { Faker::Number.between(1, 25) }
  let(:bonus_req_type) { Contract::BONUS_REQUIREMENT_TYPES.sample }

  it "has a valid factory" do
    expect(FactoryBot.create(:contract_history)).to be_valid
  end

  it 'requires a datestamp' do
    expect(FactoryBot.build(:contract_history, datestamp: nil)).to_not be_valid
  end

  it 'requires an end date' do
    expect(FactoryBot.build(:contract_history, end_date: nil)).to_not be_valid
  end

  it 'requires a wage' do
    expect(FactoryBot.build(:contract_history, wage: nil)).to_not be_valid
  end

  it 'has a valid bonus requirement type if present' do
    expect(FactoryBot.build(:contract_history, bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: Faker::Lorem.word)).to_not be_valid
  end

  it 'provides all three fields for a performance bonus' do
    expect(FactoryBot.build(:contract_history, performance_bonus: perf_bonus)).to_not be_valid
    expect(FactoryBot.build(:contract_history, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract_history, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract_history, performance_bonus: perf_bonus, bonus_req: bonus_req)).to_not be_valid
    expect(FactoryBot.build(:contract_history, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract_history, bonus_req: bonus_req, bonus_req_type: bonus_req_type)).to_not be_valid
    expect(FactoryBot.build(:contract_history, bonus_req: bonus_req, performance_bonus: perf_bonus, bonus_req_type: bonus_req_type)).to be_valid
  end

end
