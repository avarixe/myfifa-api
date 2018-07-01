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

FactoryBot.define do
  factory :contract do
    signed_date Faker::Date.between(500.days.ago, 365.days.ago)
    start_date Faker::Date.backward(365)
    end_date Faker::Date.forward(365)
    wage Faker::Number.between(1_000, 10_000_000)
    player

    transient do
      histories_count 0
    end

    after :create do |contract, evaluator|
      create_list :contract_history, evaluator.histories_count, contract: contract
    end
  end
end
