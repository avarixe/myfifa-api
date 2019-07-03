# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint(8)        not null, primary key
#  player_id         :bigint(8)
#  signed_on         :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ended_on          :date
#  started_on        :date
#
# Indexes
#
#  index_contracts_on_player_id  (player_id)
#

FactoryBot.define do
  factory :contract do
    started_on { Time.now }
    ended_on { Faker::Date.between(365.days.from_now, 1000.days.from_now) }
    wage { Faker::Number.between(1_000, 10_000_000) }
    player
  end
end
