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

FactoryBot.define do
  factory :contract_history do
    datestamp Faker::Date.backward(365)
    end_date  Faker::Date.forward(365)
    wage Faker::Number.between(1_000, 10_000_000)
    contract
  end
end
