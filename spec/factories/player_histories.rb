# frozen_string_literal: true

# == Schema Information
#
# Table name: player_histories
#
#  id          :bigint           not null, primary key
#  kit_no      :integer
#  ovr         :integer
#  recorded_on :date
#  value       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

FactoryBot.define do
  factory :player_history do
    recorded_on { Date.new }
    ovr { Faker::Number.between(from: 50, to: 90) }
    value { Faker::Number.between(from: 50_000, to: 200_000_000) }
    kit_no { Faker::Number.between(from: 1, to: 99) }
    player
  end
end
