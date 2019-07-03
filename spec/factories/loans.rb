# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  started_on  :date
#  ended_on    :date
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  origin      :string
#  signed_on   :date
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

FactoryBot.define do
  factory :loan do
    origin { Faker::Team.unique.name }
    destination { Faker::Team.unique.name }
    started_on { Faker::Date.between(Date.today, 60.days.from_now) }
    player
  end
end
