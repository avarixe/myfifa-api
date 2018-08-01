# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  title        :string
#  start_date   :date
#  current_date :date
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
    title Faker::Team.name
    start_date Time.now

    before(:create) do |team|
      team.current_date = team.start_date
    end

    factory :team_with_players do
      transient do
        players_count 11
      end

      after :create do |team, evaluator|
        create_list :player, evaluator.players_count, teams: [team]
      end
    end
  end
end
