# frozen_string_literal: true

# == Schema Information
#
# Table name: injuries
#
#  id          :bigint           not null, primary key
#  description :string
#  ended_on    :date
#  started_on  :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

FactoryBot.define do
  factory :injury do
    description { Faker::Lorem.word }
    player

    transient do
      duration { rand(1..200).days }
    end

    after(:build) do |injury, evaluator|
      if injury.ended_on.blank?
        injury.started_on ||= Faker::Date.between(
          from: Date.current,
          to: Date.current + 1.year
        )
        injury.ended_on = injury.started_on + evaluator.duration
      elsif injury.started_on.blank?
        injury.started_on = injury.ended_on - evaluator.duration
      end
    end
  end
end
