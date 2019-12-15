# frozen_string_literal: true

# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :bigint           not null, primary key
#  away_score :integer
#  home_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
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
