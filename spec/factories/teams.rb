# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  title        :string
#  started_on   :date
#  currently_on :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  currency     :string           default("$")
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

FactoryBot.define do
  factory :team do
    title { Faker::Team.name }
    started_on { Time.now }
    user

    before(:create) do |team|
      team.currently_on = team.started_on
    end

    factory :team_with_players do
      transient do
        players_count { 11 }
      end

      after :create do |team, evaluator|
        create_list :player, evaluator.players_count, team: team
      end
    end
  end
end
