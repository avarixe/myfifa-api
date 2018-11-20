# frozen_string_literal: true

# == Schema Information
#
# Table name: squads
#
#  id             :bigint(8)        not null, primary key
#  team_id        :bigint(8)
#  name           :string
#  players_list   :text             default([]), is an Array
#  positions_list :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

FactoryBot.define do
  factory :squad do
    name { Faker::Lorem.word }
    players_list { team.players.pluck(:id) }
    positions_list { Cap::POSITIONS.dup.sample(11) }
    association :team, factory: :team_with_players
  end
end
