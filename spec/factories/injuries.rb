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

    after(:build) do |injury|
      injury.started_on ||= injury.player.team.currently_on
    end
  end
end
