# == Schema Information
#
# Table name: competitions
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  season     :integer
#  name       :string
#  champion   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_competitions_on_season   (season)
#  index_competitions_on_team_id  (team_id)
#

FactoryBot.define do
  factory :competition do
    season { Faker::Number.digit }
    name { Faker::Lorem.word }
    team

    factory :league do
      preset_format { 'League' }
      num_teams { Faker::Number.between(2, 100) }
    end

    factory :cup do
      preset_format { 'Knockout' }
      num_teams { 2**Faker::Number.between(1, 6) }
    end

    factory :tournament do
      preset_format { 'Group + Knockout' }
    end
  end
end
