# == Schema Information
#
# Table name: stages
#
#  id             :bigint(8)        not null, primary key
#  competition_id :bigint(8)
#  name           :string
#  num_teams      :integer
#  num_fixtures   :integer
#  table          :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stages_on_competition_id  (competition_id)
#

FactoryBot.define do
  factory :stage do
    num_teams { Faker::Number.between(from: 1, to: 20) }
    num_fixtures { 2**Faker::Number.between(from: 1, to: 5) }
    competition
  end
end
