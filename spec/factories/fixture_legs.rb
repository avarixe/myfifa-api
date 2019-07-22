# == Schema Information
#
# Table name: fixture_legs
#
#  id         :bigint(8)        not null, primary key
#  fixture_id :bigint(8)
#  home_score :string
#  away_score :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_fixture_legs_on_fixture_id  (fixture_id)
#

FactoryBot.define do
  factory :fixture_leg do
    home_score { Faker::Number.between(0, 3) }
    away_score { Faker::Number.between(0, 3) }
    fixture
  end
end
