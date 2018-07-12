# == Schema Information
#
# Table name: matches
#
#  id                  :integer          not null, primary key
#  team_id             :integer
#  home                :string
#  away                :string
#  competition         :string
#  date_played         :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  extra_time          :boolean          default(FALSE)
#  home_score_override :integer
#  away_score_override :integer
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

FactoryBot.define do
  factory :match do
    
  end
end
