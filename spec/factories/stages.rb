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
    
  end
end
