# == Schema Information
#
# Table name: fixture_legs
#
#  id         :bigint           not null, primary key
#  away_score :string
#  home_score :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  fixture_id :bigint
#
# Indexes
#
#  index_fixture_legs_on_fixture_id  (fixture_id)
#

FactoryBot.define do
  factory :fixture_leg do
    home_score { Faker::Number.between(from: 0, to: 3) }
    away_score { Faker::Number.between(from: 0, to: 3) }
    fixture
  end
end
