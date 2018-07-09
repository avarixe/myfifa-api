# == Schema Information
#
# Table name: substitutions
#
#  id             :integer          not null, primary key
#  match_id       :integer
#  minute         :integer
#  player_id      :integer
#  replacement_id :integer
#  injury         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#

FactoryBot.define do
  factory :substitution do
    
  end
end
