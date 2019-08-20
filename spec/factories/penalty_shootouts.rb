# frozen_string_literal: true

# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  home_score :integer
#  away_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_penalty_shootouts_on_match_id  (match_id)
#

FactoryBot.define do
  factory :penalty_shootout do
    home_score { Faker::Number.unique.between(from: 0, to: 20) }
    away_score { Faker::Number.unique.between(from: 0, to: 20) }
    match
  end
end
