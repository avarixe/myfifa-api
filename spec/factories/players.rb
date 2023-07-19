# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id          :bigint           not null, primary key
#  birth_year  :integer
#  coverage    :jsonb            not null
#  kit_no      :integer
#  name        :string
#  nationality :string
#  ovr         :integer
#  pos         :string
#  sec_pos     :text             default([]), is an Array
#  status      :string
#  value       :integer
#  youth       :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :bigint
#
# Indexes
#
#  index_players_on_coverage  (coverage) USING gin
#  index_players_on_team_id   (team_id)
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
      create_list(:contract,
                  evaluator.contracts_count,
                  player:,
                  signed_on: player.team.currently_on,
                  started_on: player.team.currently_on)
    end
  end
end
