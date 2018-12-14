# == Schema Information
#
# Table name: fixtures
#
#  id         :bigint(8)        not null, primary key
#  stage_id   :bigint(8)
#  home_team  :string
#  away_team  :string
#  home_score :string
#  away_score :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_fixtures_on_stage_id  (stage_id)
#

FactoryBot.define do
  factory :fixture do
    stage

    factory :completed_fixture do
      home_team { Faker::Team.name }
      away_team { Faker::Team.name }
      home_score { Faker::Number.between(0, 3) }
      away_score { Faker::Number.between(0, 3) }
    end
  end
end
