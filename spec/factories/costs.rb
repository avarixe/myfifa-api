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

FactoryBot.define do
  factory :cost do
    type Cost::VALID_TYPES.sample
    fee Faker::Number.between(10_000, 10_000_000)
    contract
  end
end
