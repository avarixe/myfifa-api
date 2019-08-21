# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text             default([]), is an Array
#  ovr         :integer
#  value       :integer
#  birth_year  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#  youth       :boolean          default(TRUE)
#  kit_no      :integer
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

FactoryBot.define do
  factory :player do
    name { Faker::Name.unique.name }
    pos { Player::POSITIONS.sample }
    nationality { Faker::Address.country }
    birth_year { Faker::Number.between(from: 1980, to: 2000) }
    ovr { Faker::Number.between(from: 50, to: 90) }
    value { Faker::Number.between(from: 50_000, to: 200_000_000) }
    kit_no { Faker::Number.between(from: 1, to: 99) }
    team

    transient do
      contracts_count { 1 }
    end

    after :create do |player, evaluator|
      create_list :contract,
                  evaluator.contracts_count,
                  player: player,
                  started_on: player.currently_on
    end
  end
end
