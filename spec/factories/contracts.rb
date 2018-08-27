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

FactoryBot.define do
  factory :contract do
    effective_date { Time.now }
    end_date { Faker::Date.between(365.days.from_now, 1000.days.from_now) }
    wage { Faker::Number.between(1_000, 10_000_000) }
    player

    transient do
      histories_count 0
    end

    after :create do |contract, evaluator|
      create_list :contract_history, evaluator.histories_count, contract: contract
    end
  end
end
