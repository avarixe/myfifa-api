# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id          :bigint           not null, primary key
#  destination :string
#  ended_on    :date
#  origin      :string
#  signed_on   :date
#  started_on  :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_id   :bigint
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

FactoryBot.define do
  factory :loan do
    origin { Faker::Team.unique.name }
    destination { Faker::Team.unique.name }
    started_on { Faker::Date.between(from: Date.today, to: 60.days.from_now) }
    player
  end
end
