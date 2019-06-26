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
    association :team, factory: :team_with_players

    transient do
      players_count { 11 }
    end

    before :create do |squad, evaluator|
      Cap::POSITIONS.dup.sample(evaluator.players_count).each do |pos|
        player = create :player, team: squad.team
        squad.squad_players << create(:squad_player, squad: squad, player: player, pos: pos)
      end
    end
  end
end
