# == Schema Information
#
# Table name: costs
#
#  id               :integer          not null, primary key
#  contract_id      :integer
#  type             :string
#  fee              :integer
#  traded_player_id :integer
#  addon_clause     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_costs_on_contract_id  (contract_id)
#

require 'rails_helper'

RSpec.describe Cost, type: :model do
  let(:addon_clause) { Faker::Number.between(0, 100) }

  it "has a valid factory" do
    expect(FactoryBot.create(:cost)).to be_valid
  end
  
  it 'requires a type' do
    expect(FactoryBot.build(:cost, type: nil)).to_not be_valid
  end
  
  it 'requires some type of fee' do
    expect(FactoryBot.build(:cost, fee: nil)).to_not be_valid
    expect(FactoryBot.build(:cost, fee: nil, traded_player_id: Faker::Number.digit)).to be_valid
    expect(FactoryBot.build(:cost, fee: nil, addon_clause: addon_clause)).to be_valid
  end
  
  it 'has an add-on clause between 0 and 100' do
    expect(FactoryBot.build(:cost, addon_clause: Faker::Number.negative)).to_not be_valid
    expect(FactoryBot.build(:cost, addon_clause: Faker::Number.between(101, 1_000_000))).to_not be_valid
    expect(FactoryBot.build(:cost, addon_clause: addon_clause)).to be_valid
  end

end
