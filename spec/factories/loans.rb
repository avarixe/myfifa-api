# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id              :bigint           not null, primary key
#  addon_clause    :integer
#  destination     :string
#  ended_on        :date
#  origin          :string
#  signed_on       :date
#  started_on      :date
#  transfer_fee    :integer
#  wage_percentage :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  player_id       :bigint
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

FactoryBot.define do
  factory :loan do
    origin { Faker::Team.unique.name }
    destination { Faker::Team.unique.name }
    started_on { Faker::Date.between(from: Time.zone.today, to: 60.days.from_now) }
    wage_percentage { Faker::Number.between(from: 0, to: 100) }
    player

    transient do
      duration { rand(1..200).days }
    end

    after(:build) do |loan, evaluator|
      if loan.ended_on.blank?
        loan.started_on ||= Faker::Date.between(
          from: Date.current,
          to: Date.current + 1.year
        )
        loan.ended_on = loan.started_on + evaluator.duration
      elsif loan.started_on.blank?
        loan.started_on = loan.ended_on - evaluator.duration
      end
    end
  end
end
