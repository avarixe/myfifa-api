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
    name Faker::Lorem.word
    players_list (1..11).map { |i| Faker::Number.number }
    positions_list (1..11).map { |i| MatchLog::POSITIONS.sample }
    team
  end
end
