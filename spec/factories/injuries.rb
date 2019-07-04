# frozen_string_literal: true

# == Schema Information
#
# Table name: injuries
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  started_on  :date
#  ended_on    :date
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

FactoryBot.define do
  factory :injury do
    description { Faker::Lorem.word }
    player
  end
end
