# frozen_string_literal: true

# == Schema Information
#
# Table name: matches
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  home        :string
#  away        :string
#  competition :string
#  played_on   :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  extra_time  :boolean          default(FALSE)
#  home_score  :integer
#  away_score  :integer
#  stage       :string
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

FactoryBot.define do
  factory :match do
    home { Faker::Team.unique.name }
    away { Faker::Team.unique.name }
    competition { Faker::Lorem.word }
    played_on { Faker::Date.between(from: Date.today, to: 60.days.from_now) }
    team
  end
end
