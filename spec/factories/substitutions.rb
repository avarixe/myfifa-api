# frozen_string_literal: true

# == Schema Information
#
# Table name: substitutions
#
#  id             :bigint           not null, primary key
#  injury         :boolean          default(FALSE)
#  minute         :integer
#  player_name    :string
#  replaced_by    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  match_id       :bigint
#  player_id      :bigint
#  replacement_id :bigint
#
# Indexes
#
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#

FactoryBot.define do
  factory :substitution do
    minute { Faker::Number.between(from: 1, to: 90) }
    match
    player
    association :replacement, factory: :player
  end
end
